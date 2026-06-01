DELETE FROM security.type_document
WHERE (name = 'CITIZENSHIP CARD' AND abbreviation = 'CC')
   OR (name = 'FOREIGNER IDENTITY CARD' AND abbreviation = 'CE')
   OR (name = 'IDENTITY CARD' AND abbreviation = 'TI')
   OR (name = 'PASSPORT' AND abbreviation = 'PAS');