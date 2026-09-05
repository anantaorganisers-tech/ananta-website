const APPLICATIONS_SHEET_NAME = 'Applications';
const SPONSORS_SHEET_NAME = 'Sponsors';

function doPost(e) {
  try {
    const payload = parsePayload_(e);
    const isSponsorForm = payload.formType === 'sponsor';
    const sheet = getOrCreateSheet_(
      isSponsorForm ? SPONSORS_SHEET_NAME : APPLICATIONS_SHEET_NAME,
    );

    if (sheet.getLastRow() === 0) {
      sheet.appendRow(isSponsorForm ? sponsorHeaders_() : applicationHeaders_());
    }

    sheet.appendRow(
      isSponsorForm ? sponsorRow_(payload) : applicationRow_(payload),
    );

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

function applicationHeaders_() {
  return [
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
}

function sponsorHeaders_() {
  return [
    'Submitted At',
    'Name of Business/Shop',
    'Name of Owner',
    'Contact Number',
    'E-Mail Address',
    'Sponsorship Package',
    'Operational Address',
    'Deliverables',
    'Queries',
  ];
}

function applicationRow_(payload) {
  return [
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
  ];
}

function sponsorRow_(payload) {
  return [
    payload.submittedAt || new Date().toISOString(),
    payload.businessName || '',
    payload.ownerName || '',
    payload.contactNumber || '',
    payload.emailAddress || '',
    payload.sponsorshipPackage || '',
    payload.operationalAddress || '',
    payload.deliverables || '',
    payload.queries || '',
  ];
}

function getOrCreateSheet_(sheetName) {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const activeSheet = spreadsheet.getActiveSheet();
  const existing = spreadsheet.getSheetByName(sheetName);
  if (existing) {
    return existing;
  }
  if (activeSheet && activeSheet.getLastRow() === 0) {
    activeSheet.setName(sheetName);
    return activeSheet;
  }
  return spreadsheet.insertSheet(sheetName);
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
    formType: params.formType || '',
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
    businessName: params.businessName || '',
    ownerName: params.ownerName || '',
    sponsorshipPackage: params.sponsorshipPackage || '',
    operationalAddress: params.operationalAddress || '',
    deliverables: params.deliverables || '',
    queries: params.queries || '',
  };
}
