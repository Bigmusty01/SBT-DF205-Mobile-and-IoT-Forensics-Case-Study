
-- Database: sms.db (E03)
-- Purpose: Validate timestamp unit and range of message.date (expect nanoseconds since 2001-01-01)
SELECT COUNT(*) AS total_msgs, MIN(date) AS min_raw, MAX(date) AS max_raw, datetime(MIN(date)/1000000000+978307200,'unixepoch') AS min_utc, datetime(MAX(date)/1000000000+978307200,'unixepoch') AS max_utc FROM message WHERE date>0;

-- Database: sms.db (E03)
-- Purpose: List conversations with message counts
SELECT c.ROWID AS chat_id, c.chat_identifier, c.service_name, COUNT(cmj.message_id) AS msg_count FROM chat c JOIN chat_message_join cmj ON c.ROWID=cmj.chat_id GROUP BY c.ROWID ORDER BY msg_count DESC;

-- Database: sms.db (E03)
-- Purpose: Extract messages with participant, service, direction, raw and UTC time
SELECT m.ROWID AS msg_id, cmj.chat_id, h.id AS participant, m.service, m.is_from_me, CASE m.is_from_me WHEN 1 THEN 'sent' ELSE 'received' END AS direction, m.date AS raw_date_ns2001, datetime(m.date/1000000000+978307200,'unixepoch') AS date_utc, m.cache_has_attachments, m.text FROM message m LEFT JOIN handle h ON m.handle_id=h.ROWID LEFT JOIN chat_message_join cmj ON cmj.message_id=m.ROWID ORDER BY m.date;

-- Database: sms.db (E03)
-- Purpose: Attachment records linked to messages
SELECT maj.message_id, a.ROWID AS attachment_id, a.filename, a.transfer_name, a.mime_type, a.total_bytes, a.transfer_state, a.is_outgoing, a.created_date AS raw_created, datetime(a.created_date+978307200,'unixepoch') AS created_utc FROM attachment a JOIN message_attachment_join maj ON a.ROWID=maj.attachment_id ORDER BY maj.message_id;

-- Database: sms.db (E03)
-- Purpose: Reconstruct conversation containing attachment message 36 (chat_id 13)
SELECT m.ROWID AS msg_id, h.id AS participant, m.service, CASE m.is_from_me WHEN 1 THEN 'sent' ELSE 'received' END AS direction, m.date AS raw_date_ns2001, datetime(m.date/1000000000+978307200,'unixepoch') AS date_utc, m.cache_has_attachments AS has_att, m.text FROM message m LEFT JOIN handle h ON m.handle_id=h.ROWID JOIN chat_message_join cmj ON cmj.message_id=m.ROWID WHERE cmj.chat_id=13 ORDER BY m.date;

-- Database: sms.db (E03)
-- Purpose: List every attachment row named IMG_0008.JPG to avoid selecting the wrong record
SELECT a.ROWID AS att_id, maj.message_id, a.filename, a.total_bytes, a.transfer_state, a.is_outgoing, datetime(a.created_date+978307200,'unixepoch') AS created_utc FROM attachment a LEFT JOIN message_attachment_join maj ON a.ROWID=maj.attachment_id WHERE a.transfer_name='IMG_0008.JPG';

-- Database: AddressBook.sqlitedb (E04)
-- Purpose: Match SMS/iMessage participant identifiers (chat 13 and 17 and chat 2) to stored contacts
SELECT p.ROWID AS person_id, p.First, p.Last, mv.value AS identifier, mv.property FROM ABPerson p JOIN ABMultiValue mv ON mv.record_id=p.ROWID WHERE lower(mv.value) LIKE '%hickman1@me.com%' OR replace(replace(replace(replace(mv.value,'-',''),' ',''),'(',''),')','') LIKE '%9195790479%' OR replace(replace(replace(replace(mv.value,'-',''),' ',''),'(',''),')','') LIKE '%8634205597%';

-- Database: CallHistory.storedata (E05)
-- Purpose: Extract call records with direction, time and duration
SELECT Z_PK AS call_id, CAST(ZADDRESS AS TEXT) AS address, ZORIGINATED AS originated, ZANSWERED AS answered, ZDATE AS raw_date_s2001, datetime(ZDATE+978307200,'unixepoch') AS date_utc, ZDURATION AS duration_s, ZSERVICE_PROVIDER FROM ZCALLRECORD ORDER BY ZDATE;

-- Database: Accounts3.sqlite (E01)
-- Purpose: List device account associations (credential tables intentionally not queried)
SELECT a.Z_PK AS account_id, t.ZACCOUNTTYPEDESCRIPTION AS type, a.ZUSERNAME AS username, a.ZACCOUNTDESCRIPTION AS description, a.ZACTIVE AS active, a.ZDATE AS raw_date_s2001, datetime(a.ZDATE+978307200,'unixepoch') AS date_utc FROM ZACCOUNT a LEFT JOIN ZACCOUNTTYPE t ON a.ZACCOUNTTYPE=t.Z_PK ORDER BY a.Z_PK;

-- Database: Accounts3.sqlite (VerifiedBackup) (E02)
-- Purpose: List device account associations (credential tables intentionally not queried)
SELECT a.Z_PK AS account_id, t.ZACCOUNTTYPEDESCRIPTION AS type, a.ZUSERNAME AS username, a.ZACCOUNTDESCRIPTION AS description, a.ZACTIVE AS active, a.ZDATE AS raw_date_s2001, datetime(a.ZDATE+978307200,'unixepoch') AS date_utc FROM ZACCOUNT a LEFT JOIN ZACCOUNTTYPE t ON a.ZACCOUNTTYPE=t.Z_PK ORDER BY a.Z_PK;

-- Database: sms.db (E03)
-- Purpose: Corroborate iMessage account association from chat.account_login
SELECT DISTINCT service_name, account_login, last_addressed_handle FROM chat;

-- Database: healthdb_secure.sqlite (E12)
-- Purpose: Identify device product type, build, iOS version and time zone from data_provenances
SELECT origin_product_type, origin_build, origin_major_version, origin_minor_version, local_product_type, local_build, tz_name, COUNT(*) AS rows FROM data_provenances GROUP BY 1,2,3,4,5,6,7 ORDER BY rows DESC;

-- Database: healthdb_secure.sqlite (E12)
-- Purpose: List recorded devices in the Health database
SELECT ROWID, device_name, device_service, device_last_connect AS raw_s2001, datetime(device_last_connect+978307200,'unixepoch') AS last_connect_utc, device_enabled FROM devices;

-- Database: History.db (E06)
-- Purpose: Export recorded Safari visits with raw time, UTC conversion, title and URL
SELECT v.id AS visit_id, v.history_item AS item_id, v.visit_time AS raw_s2001, datetime(v.visit_time+978307200,'unixepoch') AS visit_utc, v.title, i.url, v.load_successful FROM history_visits v JOIN history_items i ON v.history_item=i.id ORDER BY v.visit_time;

-- Database: Calendar.sqlitedb (E07)
-- Purpose: Count calendar items per calendar to separate subscribed holiday calendars from user calendars
SELECT c.ROWID AS calendar_id, c.title, c.type, COUNT(i.ROWID) AS items FROM Calendar c LEFT JOIN CalendarItem i ON i.calendar_id=c.ROWID GROUP BY c.ROWID ORDER BY items DESC;

-- Database: Calendar.sqlitedb (E07)
-- Purpose: Show the most recently created calendar items with calendar name, start and creation times
SELECT i.ROWID AS item_id, c.title AS calendar, i.summary, i.start_date AS raw_start_s2001, datetime(i.start_date+978307200,'unixepoch') AS start_utc, i.all_day, i.creation_date AS raw_created, datetime(i.creation_date+978307200,'unixepoch') AS created_utc FROM CalendarItem i JOIN Calendar c ON i.calendar_id=c.ROWID ORDER BY i.creation_date DESC LIMIT 12;

-- Database: Photos.sqlite (E09)
-- Purpose: List photo/media assets with creation and added times, GPS, trash state and saved-asset type
SELECT g.Z_PK AS asset_id, g.ZDIRECTORY, g.ZFILENAME, g.ZDATECREATED AS raw_created_s2001, datetime(g.ZDATECREATED+978307200,'unixepoch') AS created_utc, g.ZADDEDDATE AS raw_added_s2001, datetime(g.ZADDEDDATE+978307200,'unixepoch') AS added_utc, g.ZLATITUDE, g.ZLONGITUDE, g.ZTRASHEDSTATE, g.ZSAVEDASSETTYPE FROM ZGENERICASSET g ORDER BY g.ZDATECREATED DESC LIMIT 15;

-- Database: Photos.sqlite (E09)
-- Purpose: Summarise assets by kind, saved-asset type, trashed and hidden state
SELECT ZKIND, ZSAVEDASSETTYPE, ZTRASHEDSTATE, ZHIDDEN, COUNT(*) AS n FROM ZGENERICASSET GROUP BY 1,2,3,4 ORDER BY n DESC;

-- Database: Photos.sqlite (E09)
-- Purpose: Extract key assets with creation/added/trashed times, GPS, time zone, EXIF string, import source, share fields and stored hash
SELECT g.Z_PK AS asset_id, g.ZDIRECTORY||'/'||g.ZFILENAME AS path, g.ZKIND AS kind, g.ZSAVEDASSETTYPE AS saved_type, g.ZTRASHEDSTATE AS trashed, g.ZTRASHEDDATE AS raw_trashed, datetime(g.ZTRASHEDDATE+978307200,'unixepoch') AS trashed_utc, g.ZDATECREATED AS raw_created, datetime(g.ZDATECREATED+978307200,'unixepoch') AS created_utc, g.ZADDEDDATE AS raw_added, datetime(g.ZADDEDDATE+978307200,'unixepoch') AS added_utc, g.ZLASTSHAREDDATE AS raw_shared, g.ZLATITUDE AS lat, g.ZLONGITUDE AS lon, a.ZORIGINALFILENAME AS orig_name, a.ZORIGINALFILESIZE AS orig_size, a.ZTIMEZONEOFFSET AS tz_offset_s, a.ZTIMEZONENAME AS tz_name, a.ZEXIFTIMESTAMPSTRING AS exif_ts, a.ZIMPORTEDBY AS imported_by, a.ZCREATORBUNDLEID AS creator_bundle, a.ZSHARETYPE AS share_type, a.ZSHARECOUNT AS share_count, a.ZORIGINALHASH AS db_hash FROM ZGENERICASSET g LEFT JOIN ZADDITIONALASSETATTRIBUTES a ON a.ZASSET=g.Z_PK WHERE g.ZFILENAME LIKE 'IMG_0008%' OR g.ZFILENAME IN ('IMG_0047.JPG','IMG_0052.JPG') ORDER BY g.ZDATECREATED;

-- Database: knowledgeC.db (E10)
-- Purpose: Summarise KnowledgeC streams with record counts and time ranges
SELECT ZSTREAMNAME, COUNT(*) AS n, datetime(MIN(ZSTARTDATE)+978307200,'unixepoch') AS first_utc, datetime(MAX(ZSTARTDATE)+978307200,'unixepoch') AS last_utc FROM ZOBJECT GROUP BY ZSTREAMNAME ORDER BY n DESC LIMIT 15;

-- Database: knowledgeC.db (E10)
-- Purpose: Extract app-focus and device-lock intervals around the message 36 attachment (12:56 UTC) and the two GPS photos (14:23-14:25 UTC) on 2020-04-12
SELECT Z_PK AS record_id, ZSTREAMNAME AS stream, ZVALUESTRING AS app_or_value, ZVALUEINTEGER AS int_value, ZSTARTDATE AS raw_start_s2001, datetime(ZSTARTDATE+978307200,'unixepoch') AS start_utc, ZENDDATE AS raw_end_s2001, datetime(ZENDDATE+978307200,'unixepoch') AS end_utc, ROUND(ZENDDATE-ZSTARTDATE,1) AS duration_s, ZSECONDSFROMGMT AS secs_from_gmt FROM ZOBJECT WHERE ZSTREAMNAME IN ('/app/inFocus','/device/isLocked') AND ZSTARTDATE BETWEEN strftime('%s','2020-04-12 12:30:00')-978307200 AND strftime('%s','2020-04-12 14:40:00')-978307200 ORDER BY ZSTARTDATE;

-- Database: CallHistory.storedata (E05)
-- Purpose: Exact call count and date range (earlier listing was truncated)
SELECT COUNT(*) AS total_calls, datetime(MIN(ZDATE)+978307200,'unixepoch') AS first_utc, datetime(MAX(ZDATE)+978307200,'unixepoch') AS last_utc FROM ZCALLRECORD;

-- Database: CallHistory.storedata (E05)
-- Purpose: Calls recorded on 2020-04-12 to compare with mobilephone focus at 12:59:58 UTC
SELECT Z_PK, CAST(ZADDRESS AS TEXT) AS address, ZORIGINATED, ZANSWERED, ZDATE AS raw_s2001, datetime(ZDATE+978307200,'unixepoch') AS date_utc, ZDURATION FROM ZCALLRECORD WHERE date(ZDATE+978307200,'unixepoch')='2020-04-12';

-- Database: knowledgeC.db (E10)
-- Purpose: App focus and lock intervals around the two GPS-tagged photos (14:23:10 and 14:25:13 UTC)
SELECT Z_PK AS record_id, ZSTREAMNAME AS stream, ZVALUESTRING AS app, CASE WHEN ZSTREAMNAME='/device/isLocked' THEN ZVALUEINTEGER END AS lock_val, ZSTARTDATE AS raw_start, datetime(ZSTARTDATE+978307200,'unixepoch') AS start_utc, datetime(ZENDDATE+978307200,'unixepoch') AS end_utc, ROUND(ZENDDATE-ZSTARTDATE,1) AS dur_s FROM ZOBJECT WHERE ZSTREAMNAME IN ('/app/inFocus','/device/isLocked') AND ZSTARTDATE BETWEEN strftime('%s','2020-04-12 14:15:00')-978307200 AND strftime('%s','2020-04-12 14:30:00')-978307200 ORDER BY ZSTARTDATE;

-- Database: Photos.sqlite (E09)
-- Purpose: Look for an IMG_0008 asset or any asset created 12:45-13:10 UTC on 2020-04-12 (message 36 window)
SELECT Z_PK, ZFILENAME, datetime(ZDATECREATED+978307200,'unixepoch') AS created_utc, ZTRASHEDSTATE FROM ZGENERICASSET WHERE ZFILENAME LIKE 'IMG_0008%' OR ZDATECREATED BETWEEN strftime('%s','2020-04-12 12:45:00')-978307200 AND strftime('%s','2020-04-12 13:10:00')-978307200 ORDER BY ZDATECREATED;

-- Database: healthdb_secure.sqlite (E12)
-- Purpose: Count samples by data_type with first and last start time
SELECT data_type, COUNT(*) AS n, datetime(MIN(start_date)+978307200,'unixepoch') AS first_utc, datetime(MAX(start_date)+978307200,'unixepoch') AS last_utc FROM samples GROUP BY data_type ORDER BY n DESC LIMIT 10;

-- Database: healthdb_secure.sqlite (E12)
-- Purpose: Extract activity samples with raw and UTC times, value and unit (data_type 10) for 2020-04-12
SELECT s.data_id, s.data_type, s.start_date AS raw_start_s2001, datetime(s.start_date+978307200,'unixepoch') AS start_utc, s.end_date AS raw_end_s2001, datetime(s.end_date+978307200,'unixepoch') AS end_utc, q.quantity, q.original_unit FROM samples s JOIN quantity_samples q ON q.data_id=s.data_id WHERE s.data_type=10 AND s.start_date BETWEEN strftime('%s','2020-04-12 00:00:00')-978307200 AND strftime('%s','2020-04-13 00:00:00')-978307200 ORDER BY s.start_date LIMIT 6;

-- Database: healthdb_secure.sqlite (E12)
-- Purpose: List workouts with start/end and totals
SELECT w.data_id, datetime(s.start_date+978307200,'unixepoch') AS start_utc, datetime(s.end_date+978307200,'unixepoch') AS end_utc, w.duration, w.total_distance, w.total_energy_burned FROM workouts w JOIN samples s ON s.data_id=w.data_id ORDER BY s.start_date;

-- Database: Local.sqlite (E13)
-- Purpose: Extract learned visits with entry/exit times (distinct from creation time) and coordinates
SELECT Z_PK, ZENTRYDATE AS raw_entry, datetime(ZENTRYDATE+978307200,'unixepoch') AS entry_utc, ZEXITDATE AS raw_exit, datetime(ZEXITDATE+978307200,'unixepoch') AS exit_utc, datetime(ZCREATIONDATE+978307200,'unixepoch') AS created_utc, ZLOCATIONLATITUDE AS lat, ZLOCATIONLONGITUDE AS lon, ZCONFIDENCE AS conf FROM ZRTLEARNEDLOCATIONOFINTERESTVISITMO ORDER BY ZENTRYDATE;

-- Database: cache_encryptedB.db (E14)
-- Purpose: Sample Wi-Fi reference locations (MAC masked)
SELECT substr(MAC,1,8)||':xx:xx:xx' AS mac_masked, Timestamp AS raw_s2001, datetime(Timestamp+978307200,'unixepoch') AS ts_utc, Latitude, Longitude, HorizontalAccuracy FROM WifiLocation ORDER BY Timestamp DESC LIMIT 3;

-- Database: cache_encryptedB.db (E14)
-- Purpose: Sample LTE cell reference locations
SELECT MCC, MNC, CI, TAC, Timestamp AS raw_s2001, datetime(Timestamp+978307200,'unixepoch') AS ts_utc, Latitude, Longitude, HorizontalAccuracy FROM LteCellLocation ORDER BY Timestamp DESC LIMIT 3;

-- ===== Timeline.csv event queries =====

-- Database: Accounts3.sqlite (E01)
-- Purpose: Timeline event, account 12
SELECT a.ZDATE, t.ZACCOUNTTYPEDESCRIPTION FROM ZACCOUNT a LEFT JOIN ZACCOUNTTYPE t ON a.ZACCOUNTTYPE=t.Z_PK WHERE a.Z_PK=12;

-- Database: Photos.sqlite (E09)
-- Purpose: Timeline event, asset 8
SELECT ZDATECREATED, ZDIRECTORY||'/'||ZFILENAME FROM ZGENERICASSET WHERE Z_PK=8;

-- Database: CallHistory.storedata (E05)
-- Purpose: Timeline event, call 31
SELECT ZDATE, CASE ZORIGINATED WHEN 1 THEN 'outgoing' ELSE 'incoming' END||', duration '||ROUND(ZDURATION,1)||' s, answered flag '||ZANSWERED FROM ZCALLRECORD WHERE Z_PK=31;

-- Database: History.db (E06)
-- Purpose: Timeline event, visit 2
SELECT visit_time, title FROM history_visits WHERE id=2;

-- Database: History.db (E06)
-- Purpose: Timeline event, visit 11
SELECT visit_time, title FROM history_visits WHERE id=11;

-- Database: CallHistory.storedata (E05)
-- Purpose: Timeline event, call 56
SELECT ZDATE, CASE ZORIGINATED WHEN 1 THEN 'outgoing' ELSE 'incoming' END||', duration '||ROUND(ZDURATION,1)||' s, answered flag '||ZANSWERED FROM ZCALLRECORD WHERE Z_PK=56;

-- Database: sms.db (E03)
-- Purpose: Timeline event, message 34
SELECT date,'' FROM message WHERE ROWID=34;

-- Database: knowledgeC.db (E10)
-- Purpose: Timeline event, record 17236
SELECT ZSTARTDATE, ZVALUESTRING||' (focus '||ROUND(ZENDDATE-ZSTARTDATE,1)||' s)' FROM ZOBJECT WHERE Z_PK=17236;

-- Database: knowledgeC.db (E10)
-- Purpose: Timeline event, record 17230
SELECT ZSTARTDATE, ZVALUESTRING||' (focus '||ROUND(ZENDDATE-ZSTARTDATE,1)||' s)' FROM ZOBJECT WHERE Z_PK=17230;

-- Database: knowledgeC.db (E10)
-- Purpose: Timeline event, record 17233
SELECT ZSTARTDATE, ZVALUESTRING||' (focus '||ROUND(ZENDDATE-ZSTARTDATE,1)||' s)' FROM ZOBJECT WHERE Z_PK=17233;

-- Database: sms.db (E03)
-- Purpose: Timeline event, attachment 2
SELECT created_date,transfer_name FROM attachment WHERE ROWID=2;

-- Database: sms.db (E03)
-- Purpose: Timeline event, attachment 3
SELECT created_date,transfer_name FROM attachment WHERE ROWID=3;

-- Database: sms.db (E03)
-- Purpose: Timeline event, message 36
SELECT date,'' FROM message WHERE ROWID=36;

-- Database: Photos.sqlite (E09)
-- Purpose: Timeline event, asset 38
SELECT ZDATECREATED, ZDIRECTORY||'/'||ZFILENAME FROM ZGENERICASSET WHERE Z_PK=38;

-- Database: Local.sqlite (E13)
-- Purpose: Timeline event, visit 963
SELECT ZEXITDATE,'' FROM ZRTLEARNEDLOCATIONOFINTERESTVISITMO WHERE Z_PK=963;

-- Database: Local.sqlite (E13)
-- Purpose: Timeline event, visit 967
SELECT ZEXITDATE,'' FROM ZRTLEARNEDLOCATIONOFINTERESTVISITMO WHERE Z_PK=967;

-- Database: knowledgeC.db (E10)
-- Purpose: Timeline event, record 17483
SELECT ZSTARTDATE, ZVALUESTRING||' (focus '||ROUND(ZENDDATE-ZSTARTDATE,1)||' s)' FROM ZOBJECT WHERE Z_PK=17483;

-- Database: Photos.sqlite (E09)
-- Purpose: Timeline event, asset 47
SELECT ZDATECREATED, ZDIRECTORY||'/'||ZFILENAME FROM ZGENERICASSET WHERE Z_PK=47;

-- Database: Photos.sqlite (E09)
-- Purpose: Timeline event, asset 52
SELECT ZDATECREATED, ZDIRECTORY||'/'||ZFILENAME FROM ZGENERICASSET WHERE Z_PK=52;

-- Database: knowledgeC.db (E10)
-- Purpose: Timeline event, record 17490
SELECT ZSTARTDATE, ZVALUESTRING||' (focus '||ROUND(ZENDDATE-ZSTARTDATE,1)||' s)' FROM ZOBJECT WHERE Z_PK=17490;

-- Database: Local.sqlite (E13)
-- Purpose: Timeline event, visit 956
SELECT ZENTRYDATE,'' FROM ZRTLEARNEDLOCATIONOFINTERESTVISITMO WHERE Z_PK=956;

-- Database: CallHistory.storedata (E05)
-- Purpose: Timeline event, call 58
SELECT ZDATE, CASE ZORIGINATED WHEN 1 THEN 'outgoing' ELSE 'incoming' END||', duration '||ROUND(ZDURATION,1)||' s, answered flag '||ZANSWERED FROM ZCALLRECORD WHERE Z_PK=58;

-- Database: CallHistory.storedata (E05)
-- Purpose: Timeline event, call 59
SELECT ZDATE, CASE ZORIGINATED WHEN 1 THEN 'outgoing' ELSE 'incoming' END||', duration '||ROUND(ZDURATION,1)||' s, answered flag '||ZANSWERED FROM ZCALLRECORD WHERE Z_PK=59;

-- Database: healthdb_secure.sqlite (E12) attached to healthdb.sqlite (E11)
-- Purpose: Link sample/workout records to their data source and device via data_provenances
ATTACH '/home/kali/work/db/E11/healthdb.sqlite' AS h;
SELECT 'sample' AS kind, s.data_id, s.data_type, datetime(s.start_date+978307200,'unixepoch') AS start_utc, q.quantity, q.original_unit, src.name AS source_name, src.bundle_id, dev.model, dev.software FROM samples s JOIN quantity_samples q ON q.data_id=s.data_id JOIN objects o ON o.data_id=s.data_id JOIN data_provenances p ON p.ROWID=o.provenance LEFT JOIN h.sources src ON src.ROWID=p.source_id LEFT JOIN h.source_devices dev ON dev.ROWID=p.device_id WHERE s.data_id IN (45327,45496,45502,45503,45504,46551);
SELECT 'workout' AS kind, w.data_id, datetime(s.start_date+978307200,'unixepoch') AS start_utc, src.name AS source_name, dev.model, dev.software FROM workouts w JOIN samples s ON s.data_id=w.data_id JOIN objects o ON o.data_id=w.data_id JOIN data_provenances p ON p.ROWID=o.provenance LEFT JOIN h.sources src ON src.ROWID=p.source_id LEFT JOIN h.source_devices dev ON dev.ROWID=p.device_id ORDER BY s.start_date;
SELECT src.name AS source_name, dev.model, COUNT(*) AS samples FROM samples s JOIN objects o ON o.data_id=s.data_id JOIN data_provenances p ON p.ROWID=o.provenance LEFT JOIN h.sources src ON src.ROWID=p.source_id LEFT JOIN h.source_devices dev ON dev.ROWID=p.device_id GROUP BY 1,2 ORDER BY samples DESC;
