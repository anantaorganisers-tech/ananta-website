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

function getOrCreateSheet_() {
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
