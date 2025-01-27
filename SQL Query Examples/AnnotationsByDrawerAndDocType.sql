/* 
Gives count of annoations by Annotation Name, Drawer and Document type.
*/
SELECT DISTINCT dwr.DRAWER_NAME, dt.DOC_TYPE_NAME, t.TEMPL_NAME, COUNT(DISTINCT subob.SUBOB_ID) as annotation_count
FROM inuser.IN_DOC doc
INNER JOIN inuser.IN_DRAWER dwr on dwr.DRAWER_ID = doc.DRAWER_ID
INNER JOIN inuser.IN_DOC_TYPE dt on dt.DOC_TYPE_ID = doc.DOC_TYPE_ID
INNER JOIN inuser.IN_VERSION version ON version.DOC_ID = doc.DOC_ID
INNER JOIN inuser.IN_LOGOB logob ON logob.VERSION_ID = version.VERSION_ID
INNER JOIN inuser.IN_LOGOB_SUBOB logob_subob ON  logob_subob.LOGOB_ID = logob.LOGOB_ID
INNER JOIN inuser.IN_SUBOB subob ON subob.SUBOB_ID = logob_subob.SUBOB_ID
INNER JOIN inuser.IN_SUBOB_TEMPL t on t.SUBOB_TEMPL_ID = subob.SUBOB_TEMPL_ID
GROUP BY dwr.DRAWER_NAME, dt.DOC_TYPE_NAME, t.TEMPL_NAME
ORDER BY dwr.DRAWER_NAME, dt.DOC_TYPE_NAME, t.TEMPL_NAME
