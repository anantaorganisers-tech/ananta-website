const APPLICATIONS_SHEET_NAME = 'Applications';
const ONE_ACT_SHEET_NAME = 'OneAct';
const ONE_ACT_BROCHURE_FOLDER_NAME = 'Rangaksh One Act Brochures';
const VISITOR_PASS_SHEET_NAME = 'VisitorPass';
const VISITOR_PASS_QR_FOLDER_NAME = 'Rangaksh Visitor Pass QR Codes';
const SPONSOR_SHEET_NAME = 'Sponsors';
const STALL_REQUESTS_SHEET_NAME = 'StallRequests';
const MAX_BROCHURE_BYTES = 10 * 1024 * 1024;
const MAX_QR_IMAGE_BYTES = 2 * 1024 * 1024;
const VISITOR_AUDIENCE_PRICE = 80;
const VISITOR_DJ_GARBA_PRICE = 200;
const VISITOR_DJ_GARBA_BULK_PRICE = 150;
const VISITOR_DJ_GARBA_BULK_MIN_TICKETS = 5;

const APPLICATION_HEADERS = [
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
];

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
  'Pass QR Code Links',
  'Package',
  'Ticket Count',
];

const SPONSOR_HEADERS = [
  'Submitted At',
  'Business/Shop Name',
  'Owner Name',
  'Contact Number',
  'E-Mail Address',
  'Sponsorship Package',
  'Operational Address',
  'Deliverables',
  'Queries',
  'Approval Status',
];

const STALL_REQUEST_HEADERS = [
  'Submitted At',
  'Owner Name',
  'Shop Name',
  'Type of Shop',
  'Time of Day for Stall',
  'Contact Number',
  'E-Mail Address',
  'Approval Status',
];

function doPost(e) {
  try {
    const payload = parsePayload_(e);

    if (payload.formType === 'oneActPayment') {
      return saveOneActPayment_(payload);
    }
    if (payload.formType === 'visitorPassPayment') {
      return saveVisitorPassPayment_(payload);
    }
    if (payload.formType === 'visitorPassQr') {
      return saveVisitorPassQr_(payload);
    }
    if (payload.formType === 'sponsor') {
      return saveSponsorApplication_(payload);
    }
    if (payload.formType === 'stallSetup') {
      return saveStallRequest_(payload);
    }

    return saveSecretariatApplication_(payload);
  } catch (error) {
    return jsonResponse_({
      success: false,
      message: error && error.message ? error.message : String(error),
    });
  }
}

// Run this once from the Apps Script editor to grant Drive access for uploads.
function authorizeOneActDrive() {
  getOrCreateBrochureFolder_();
  getOrCreateVisitorPassQrFolder_();
}

function saveSecretariatApplication_(payload) {
  const sheet = getOrCreateSheet_(APPLICATIONS_SHEET_NAME);
  ensureHeaders_(sheet, APPLICATION_HEADERS);

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

function saveSponsorApplication_(payload) {
  validateSponsorPayload_(payload);

  const sheet = getOrCreateSheet_(SPONSOR_SHEET_NAME);
  ensureHeaders_(sheet, SPONSOR_HEADERS);
  sheet.appendRow([
    payload.submittedAt || new Date().toISOString(),
    payload.businessName || '',
    payload.ownerName || '',
    payload.contactNumber || '',
    payload.emailAddress || '',
    payload.sponsorshipPackage || '',
    payload.operationalAddress || '',
    payload.deliverables || '',
    payload.queries || '',
    'Pending',
  ]);

  return jsonResponse_({success: true, row: sheet.getLastRow()});
}

function saveStallRequest_(payload) {
  validateStallRequestPayload_(payload);

  const sheet = getOrCreateSheet_(STALL_REQUESTS_SHEET_NAME);
  ensureHeaders_(sheet, STALL_REQUEST_HEADERS);
  sheet.appendRow([
    payload.submittedAt || new Date().toISOString(),
    payload.ownerName || '',
    payload.shopName || '',
    payload.shopType || '',
    payload.stallTime || '',
    payload.contactNumber || '',
    payload.emailAddress || '',
    'Pending',
  ]);

  return jsonResponse_({success: true, row: sheet.getLastRow()});
}

function saveOneActPayment_(payload) {
  validateOneActPayload_(payload);

  const sheet = getOrCreateSheet_(ONE_ACT_SHEET_NAME);
  ensureHeaders_(sheet, ONE_ACT_HEADERS);
  if (findMatchingRow_(sheet, 13, payload.transactionId)) {
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
    .setFormula(
      '=HYPERLINK("' + escapeFormulaString_(brochureUrl) + '", "View PDF")',
    );

  return jsonResponse_({success: true, row: row});
}

function saveVisitorPassPayment_(payload) {
  validateVisitorPassPayload_(payload);

  const sheet = getOrCreateSheet_(VISITOR_PASS_SHEET_NAME);
  ensureHeaders_(sheet, VISITOR_PASS_HEADERS);
  const existingRow = findMatchingRow_(sheet, 7, payload.transactionId);
  const passIds = readJsonArray_(payload.passIds, payload.passId);
  const ticketCount = Number(payload.ticketCount || passIds.length);

  if (existingRow) {
    const existingPassId = sheet.getRange(existingRow, 2).getDisplayValue();
    const qrLink = sheet.getRange(existingRow, 11).getDisplayValue();
    if (!qrLink) {
      saveVisitorPassQrLinksAtRow_(
        sheet,
        existingRow,
        existingPassId ? existingPassId.split(/\s+/).filter(Boolean) : passIds,
        payload.qrBaseUrl
      );
    }
    return jsonResponse_({
      success: true,
      passId: existingPassId || passIds[0],
      passIds: existingPassId
        ? existingPassId.split(/\s+/).filter(Boolean)
        : passIds,
      existing: true,
    });
  }

  if (
    passIds.some(function (passId) {
      return passIdAlreadyRecorded_(sheet, passId);
    })
  ) {
    throw new Error('Could not allocate a unique pass ID. Please submit again.');
  }

  const recordedAt = new Date().toISOString();
  sheet.appendRow([
    payload.submittedAt || recordedAt,
    passIds.join('\n'),
    payload.name || '',
    payload.emailAddress || '',
    payload.phoneNumber || '',
    payload.upiId || '',
    payload.transactionId || '',
    Number(payload.amount),
    'Payment details submitted',
    recordedAt,
    '',
    payload.packageName || '',
    ticketCount,
  ]);

  saveVisitorPassQrLinksAtRow_(
    sheet,
    sheet.getLastRow(),
    passIds,
    payload.qrBaseUrl
  );

  return jsonResponse_({success: true, passId: passIds[0], passIds: passIds});
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
  saveVisitorPassQrsAtRow_(sheet, row, [passId], [qrImageBase64]);
}

function saveVisitorPassQrLinksAtRow_(sheet, row, passIds, qrBaseUrl) {
  const links = passIds.map(function (passId) {
    return {
      passId: passId,
      url: buildVisitorPassQrUrl_(passId, qrBaseUrl),
    };
  });

  const text = links
    .map(function (linkInfo, index) {
      return 'QR ' + (index + 1) + ': ' + linkInfo.passId;
    })
    .join('\n');
  const builder = SpreadsheetApp.newRichTextValue().setText(text);
  let offset = 0;
  links.forEach(function (linkInfo, index) {
    const label = 'QR ' + (index + 1) + ': ' + linkInfo.passId;
    builder.setLinkUrl(offset, offset + label.length, linkInfo.url);
    offset += label.length + 1;
  });
  sheet.getRange(row, 11).setRichTextValue(builder.build());
}

function buildVisitorPassQrUrl_(passId, qrBaseUrl) {
  const properties = PropertiesService.getScriptProperties();
  const baseUrl =
    qrBaseUrl || properties.getProperty('VISITOR_PASS_QR_BASE_URL');
  if (!baseUrl) {
    throw new Error(
      'Missing script property: VISITOR_PASS_QR_BASE_URL. Set it to your Vercel /api/qr URL.'
    );
  }
  const separator = baseUrl.indexOf('?') === -1 ? '?' : '&';
  return baseUrl + separator + 'id=' + encodeURIComponent(passId);
}

function saveVisitorPassQrsAtRow_(sheet, row, passIds, qrImagesBase64) {
  if (passIds.length !== qrImagesBase64.length) {
    throw new Error('Every pass ID must have a matching QR image.');
  }

  const files = passIds.map(function (passId, index) {
    return saveVisitorPassQrFile_(passId, qrImagesBase64[index]);
  });

  const text = files
    .map(function (fileInfo, index) {
      return 'QR ' + (index + 1) + ': ' + fileInfo.passId;
    })
    .join('\n');
  const builder = SpreadsheetApp.newRichTextValue().setText(text);
  let offset = 0;
  files.forEach(function (fileInfo, index) {
    const label = 'QR ' + (index + 1) + ': ' + fileInfo.passId;
    builder.setLinkUrl(offset, offset + label.length, fileInfo.url);
    offset += label.length + 1;
  });
  sheet.getRange(row, 11).setRichTextValue(builder.build());
}

function saveVisitorPassQrFile_(passId, qrImageBase64) {
  const imageBytes = Utilities.base64Decode(qrImageBase64);
  if (imageBytes.length > MAX_QR_IMAGE_BYTES) {
    throw new Error('The generated QR image is too large.');
  }

  const folder = getOrCreateVisitorPassQrFolder_();
  const file = folder.createFile(
    Utilities.newBlob(imageBytes, MimeType.PNG, safeFileName_(passId) + '.png'),
  );
  shareFileWithLink_(file);
  return {passId: passId, url: file.getUrl()};
}

function validateSponsorPayload_(payload) {
  [
    'businessName',
    'ownerName',
    'contactNumber',
    'emailAddress',
    'sponsorshipPackage',
    'operationalAddress',
    'deliverables',
  ].forEach(function (field) {
    if (!payload[field]) {
      throw new Error('Missing required field: ' + field);
    }
  });
}

function validateStallRequestPayload_(payload) {
  [
    'ownerName',
    'shopName',
    'shopType',
    'stallTime',
    'contactNumber',
    'emailAddress',
  ].forEach(function (field) {
    if (!payload[field]) {
      throw new Error('Missing required field: ' + field);
    }
  });
}

function validateOneActPayload_(payload) {
  [
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
  ].forEach(function (field) {
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
    'ticketCount',
    'upiId',
    'transactionId',
    'passId',
  ].forEach(function (field) {
    if (!payload[field]) {
      throw new Error('Missing required field: ' + field);
    }
  });

  const amount = Number(payload.amount);
  const ticketCount = Number(payload.ticketCount);
  if (!Number.isInteger(ticketCount) || ticketCount < 1 || ticketCount > 20) {
    throw new Error('Invalid ticket count.');
  }

  const passIds = readJsonArray_(payload.passIds, payload.passId);
  if (passIds.length !== ticketCount) {
    throw new Error('The ticket count does not match the generated passes.');
  }

  const expectedAmount = expectedVisitorPassAmount_(
    payload.packageName,
    ticketCount,
  );
  if (amount !== expectedAmount) {
    throw new Error(
      'Invalid visitor pass amount. Received ₹' +
        amount +
        ' for ' +
        ticketCount +
        ' ticket(s), expected ₹' +
        expectedAmount +
        '.',
    );
  }
}

function expectedVisitorPassAmount_(packageName, ticketCount) {
  const normalizedPackage = String(packageName || '').toUpperCase();
  const hasCompetition = normalizedPackage.indexOf('COMPETITION') !== -1;
  const hasDjGarba =
    normalizedPackage.indexOf('DJ') !== -1 ||
    normalizedPackage.indexOf('GARBA') !== -1;
  let perTicketAmount = 0;

  if (hasCompetition) {
    perTicketAmount += VISITOR_AUDIENCE_PRICE;
  }
  if (hasDjGarba) {
    perTicketAmount +=
      !hasCompetition && ticketCount >= VISITOR_DJ_GARBA_BULK_MIN_TICKETS
        ? VISITOR_DJ_GARBA_BULK_PRICE
        : VISITOR_DJ_GARBA_PRICE;
  }
  if (perTicketAmount <= 0) {
    throw new Error('Invalid visitor pass package.');
  }

  return perTicketAmount * ticketCount;
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
  try {
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
  } catch (error) {
    console.warn('Could not enable link sharing for file: ' + error);
  }
}

function getOrCreateSheet_(sheetName) {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const existing = spreadsheet.getSheetByName(sheetName);
  if (existing) {
    return existing;
  }
  return spreadsheet.insertSheet(sheetName);
}

function ensureHeaders_(sheet, headers) {
  if (sheet.getLastRow() !== 0) {
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    sheet.setFrozenRows(1);
    return;
  }
  sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
  sheet.setFrozenRows(1);
}

function findMatchingRow_(sheet, column, value) {
  if (!value || sheet.getLastRow() < 2) {
    return 0;
  }

  const values = sheet
    .getRange(2, column, sheet.getLastRow() - 1, 1)
    .getDisplayValues();
  const target = String(value).trim();
  for (let index = 0; index < values.length; index++) {
    if (values[index][0].trim() === target) {
      return index + 2;
    }
  }
  return 0;
}

function passIdAlreadyRecorded_(sheet, passId) {
  if (!passId || sheet.getLastRow() < 2) {
    return false;
  }

  const values = sheet
    .getRange(2, 2, sheet.getLastRow() - 1, 1)
    .getDisplayValues();
  const target = String(passId).trim();
  return values.some(function (row) {
    return row[0].split(/\s+/).some(function (recordedPassId) {
      return recordedPassId.trim() === target;
    });
  });
}

function parsePayload_(e) {
  const postData = e && e.postData ? e.postData : null;
  const rawBody = postData && postData.contents ? postData.contents : '';
  const mimeType = postData && postData.type ? postData.type : '';

  if (mimeType.indexOf('application/json') !== -1 && rawBody) {
    return JSON.parse(rawBody);
  }

  const params = e && e.parameter ? e.parameter : {};
  const payload = {};
  Object.keys(params).forEach(function (key) {
    payload[key] = params[key];
  });
  return payload;
}

function readJsonArray_(rawValue, fallbackValue) {
  if (rawValue) {
    try {
      const parsed = JSON.parse(rawValue);
      if (Array.isArray(parsed)) {
        return parsed.map(function (value) {
          return String(value);
        });
      }
    } catch (error) {
      throw new Error('Invalid array payload.');
    }
  }

  return fallbackValue ? [String(fallbackValue)] : [];
}

function safeFileName_(value) {
  return String(value || 'upload')
    .replace(/[\\/:*?"<>|#%{}~&]/g, '_')
    .replace(/^\.+/, '')
    .substring(0, 120);
}

function escapeFormulaString_(value) {
  return String(value || '').replace(/"/g, '""');
}

function jsonResponse_(body) {
  return ContentService.createTextOutput(JSON.stringify(body)).setMimeType(
    ContentService.MimeType.JSON,
  );
}
