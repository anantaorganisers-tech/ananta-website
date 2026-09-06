const APPLICATIONS_SHEET_NAME = 'Applications';
const ONE_ACT_SHEET_NAME = 'OneAct';
const ONE_ACT_BROCHURE_FOLDER_NAME = 'Rangaksh One Act Brochures';
const VISITOR_PASS_SHEET_NAME = 'VisitorPass';
const VISITOR_PASS_QR_FOLDER_NAME = 'Rangaksh Visitor Pass QR Codes';
const MAX_BROCHURE_BYTES = 10 * 1024 * 1024;
const MAX_QR_IMAGE_BYTES = 2 * 1024 * 1024;

const ONE_ACT_HEADERS = [
  'Submitted At',
  'Team Director Name',
  'Category',
  'School',
  'Contact Number',
  'E-Mail Address',
  'State',
  'Past Events Attended',
  'Number of Team Members',
  'Referral Name from Team Rangaksh',
  'Brochure (PDF)',
  'UPI ID',
  'Transaction ID',
  'Payment Status',
  'Payment Recorded At',
  'Approval Status',
];

const VISITOR_PASS_HEADERS = [
  'Submitted At',
  'PASS_ID',
  'Name',
  'E-Mail Address',
  'Phone Number',
  'UPI ID',
  'Transaction ID',
  'Amount (INR)',
  'Payment Status',
  'Payment Recorded At',
  'Pass QR Screenshot',
  'Package',
];
const SHEET_NAME = 'Applications';

function doPost(e) {
  try {
    const payload = parsePayload_(e);
    const sheet = getOrCreateSheet_();

    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'Submitted At',
        'Name',
        'Class',
        'School',
        'Contact Number',
        'E-Mail Address',
        'Address',
        'Past Experience (If Any)',
        'A Short Description of your Skillsets',
        'How much time can you contribute to Rangaksh?',
        'Preferred Department',
        'Referral name from Team Rangaksh',
      ]);
    }

    sheet.appendRow([
      payload.submittedAt || new Date().toISOString(),
      payload.name || '',
      payload.studentClass || '',
      payload.school || '',
      payload.contactNumber || '',
      payload.emailAddress || '',
      payload.address || '',
      payload.pastExperience || '',
      payload.skillsets || '',
      payload.timeContribution || '',
      payload.preferredDepartment || '',
      payload.referralName || '',
    ]);

  sheet.appendRow([
    payload.submittedAt || new Date().toISOString(),
    payload.name || '',
    payload.studentClass || '',
    payload.school || '',
    payload.contactNumber || '',
    payload.emailAddress || '',
    payload.address || '',
    payload.pastExperience || '',
    payload.skillsets || '',
    payload.timeContribution || '',
    payload.preferredDepartment || '',
    payload.referralName || '',
  ]);

  return jsonResponse_({success: true});
}

function saveOneActPayment_(payload) {
  validateOneActPayload_(payload);

  const sheet = getOrCreateSheet_(ONE_ACT_SHEET_NAME);
  ensureHeaders_(sheet, ONE_ACT_HEADERS);
  if (transactionAlreadyRecorded_(sheet, payload.transactionId)) {
    throw new Error('This transaction ID has already been recorded.');
  }

  const brochureUrl = saveBrochure_(payload);
  const recordedAt = new Date().toISOString();
  sheet.appendRow([
    payload.submittedAt || recordedAt,
    payload.directorName || '',
    payload.category || '',
    payload.school || '',
    payload.contactNumber || '',
    payload.emailAddress || '',
    payload.state || '',
    payload.pastEvents || '',
    payload.teamMembers || '',
    payload.referralName || '',
    '',
    payload.upiId || '',
    payload.transactionId || '',
    'Payment details submitted',
    recordedAt,
    'Pending',
  ]);

  const row = sheet.getLastRow();
  sheet
    .getRange(row, 11)
    .setFormula('=HYPERLINK("' + escapeFormulaString_(brochureUrl) + '", "View PDF")');

  return jsonResponse_({success: true, row: row});
}

function saveVisitorPassPayment_(payload) {
  validateVisitorPassPayload_(payload);

  const sheet = getOrCreateSheet_(VISITOR_PASS_SHEET_NAME);
  ensureHeaders_(sheet, VISITOR_PASS_HEADERS);
  const existingRow = findMatchingRow_(sheet, 7, payload.transactionId);
  if (existingRow) {
    const qrLink = sheet.getRange(existingRow, 11).getDisplayValue();
    if (!qrLink) {
      // Recover records created by the earlier two-request pass flow.
      sheet.getRange(existingRow, 2).setValue(payload.passId);
      saveVisitorPassQrAtRow_(
        sheet,
        existingRow,
        payload.passId,
        payload.qrImageBase64,
      );
      return jsonResponse_({success: true, passId: payload.passId, repaired: true});
    }
    return jsonResponse_({
      success: true,
      passId: sheet.getRange(existingRow, 2).getDisplayValue(),
      existing: true,
    });
  }

  const passId = payload.passId;
  if (findMatchingRow_(sheet, 2, passId)) {
    throw new Error('Could not allocate a unique pass ID. Please submit again.');
  }
  const recordedAt = new Date().toISOString();
  const amount = Number(payload.amount);
  sheet.appendRow([
    payload.submittedAt || recordedAt,
    passId,
    payload.name || '',
    payload.emailAddress || '',
    payload.phoneNumber || '',
    payload.upiId || '',
    payload.transactionId || '',
    amount,
    'Payment details submitted',
    recordedAt,
    '',
    payload.packageName || '',
  ]);
  saveVisitorPassQrAtRow_(
    sheet,
    sheet.getLastRow(),
    passId,
    payload.qrImageBase64,
  );

  return jsonResponse_({success: true, passId: passId});
}

function saveVisitorPassQr_(payload) {
  if (!payload.passId || !payload.qrImageBase64) {
    throw new Error('A pass ID and QR image are required.');
  }

  const sheet = getOrCreateSheet_(VISITOR_PASS_SHEET_NAME);
  ensureHeaders_(sheet, VISITOR_PASS_HEADERS);
  const row = findMatchingRow_(sheet, 2, payload.passId);
  if (!row) {
    throw new Error('The visitor pass could not be found.');
  }

  saveVisitorPassQrAtRow_(sheet, row, payload.passId, payload.qrImageBase64);

  return jsonResponse_({success: true});
}

function saveVisitorPassQrAtRow_(sheet, row, passId, qrImageBase64) {
  const imageBytes = Utilities.base64Decode(qrImageBase64);
  if (imageBytes.length > MAX_QR_IMAGE_BYTES) {
    throw new Error('The generated QR image is too large.');
  }

  const folder = getOrCreateVisitorPassQrFolder_();
  const file = folder.createFile(
    Utilities.newBlob(imageBytes, MimeType.PNG, safeFileName_(passId) + '.png'),
  );
  shareFileWithLink_(file);
  sheet
    .getRange(row, 11)
    .setFormula('=HYPERLINK("' + escapeFormulaString_(file.getUrl()) + '", "View QR screenshot")');
}

function validateOneActPayload_(payload) {
  const requiredFields = [
    'directorName',
    'category',
    'school',
    'contactNumber',
    'emailAddress',
    'state',
    'teamMembers',
    'brochureName',
    'brochureBase64',
    'upiId',
    'transactionId',
  ];
  requiredFields.forEach(function (field) {
    if (!payload[field]) {
      throw new Error('Missing required field: ' + field);
    }
  });
}

function validateVisitorPassPayload_(payload) {
  [
    'name',
    'emailAddress',
    'phoneNumber',
    'packageName',
    'amount',
    'upiId',
    'transactionId',
    'passId',
    'qrImageBase64',
  ].forEach(
    function (field) {
      if (!payload[field]) {
        throw new Error('Missing required field: ' + field);
      }
    },
  );
  const amount = Number(payload.amount);
  if (![50, 150, 200].includes(amount)) {
    throw new Error('Invalid visitor pass amount.');
  }
}

function saveBrochure_(payload) {
  const brochureBytes = Utilities.base64Decode(payload.brochureBase64);
  if (brochureBytes.length > MAX_BROCHURE_BYTES) {
    throw new Error('The brochure PDF must be 10 MB or smaller.');
  }

  const folder = getOrCreateBrochureFolder_();
  const name = new Date().getTime() + '_' + safeFileName_(payload.brochureName);
  const blob = Utilities.newBlob(brochureBytes, MimeType.PDF, name);
  const file = folder.createFile(blob);

  shareFileWithLink_(file);

  return file.getUrl();
}

function getOrCreateBrochureFolder_() {
  const folders = DriveApp.getFoldersByName(ONE_ACT_BROCHURE_FOLDER_NAME);
  return folders.hasNext()
    ? folders.next()
    : DriveApp.createFolder(ONE_ACT_BROCHURE_FOLDER_NAME);
}

function getOrCreateVisitorPassQrFolder_() {
  const folders = DriveApp.getFoldersByName(VISITOR_PASS_QR_FOLDER_NAME);
  return folders.hasNext()
    ? folders.next()
    : DriveApp.createFolder(VISITOR_PASS_QR_FOLDER_NAME);
}

function shareFileWithLink_(file) {
  // Link access lets organisers open uploaded files directly from the sheet.
  try {
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    return ContentService.createTextOutput(
      JSON.stringify({'success': true}),
    ).setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(
      JSON.stringify({
        'success': false,
        'message': String(error),
      }),
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

function getOrCreateSheet_(sheetName) {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const activeSheet = spreadsheet.getActiveSheet();
  const existing = spreadsheet.getSheetByName(SHEET_NAME);
  if (existing) {
    return existing;
  }
  if (activeSheet) {
    activeSheet.setName(SHEET_NAME);
    return activeSheet;
  }
  return spreadsheet.insertSheet(SHEET_NAME);
}

function parsePayload_(e) {
  const postData = e && e.postData ? e.postData : null;
  const rawBody = postData && postData.contents ? postData.contents : '';
  const mimeType = postData && postData.type ? postData.type : '';

  if (mimeType.indexOf('application/json') !== -1 && rawBody) {
    return JSON.parse(rawBody);
  }

  const params = e && e.parameter ? e.parameter : {};

  return {
    submittedAt: params.submittedAt || '',
    name: params.name || '',
    studentClass: params.studentClass || '',
    school: params.school || '',
    contactNumber: params.contactNumber || '',
    emailAddress: params.emailAddress || '',
    address: params.address || '',
    pastExperience: params.pastExperience || '',
    skillsets: params.skillsets || '',
    timeContribution: params.timeContribution || '',
    preferredDepartment: params.preferredDepartment || '',
    referralName: params.referralName || '',
  };
}
