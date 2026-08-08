const SHEET_NAME = 'Secretariat Applications';

function doPost(e) {
  try {
    const payload = JSON.parse(e.postData.contents || '{}');
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
  const existing = spreadsheet.getSheetByName(SHEET_NAME);
  return existing || spreadsheet.insertSheet(SHEET_NAME);
}
