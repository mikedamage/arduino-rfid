BEGIN TRANSACTION;
CREATE TABLE `users` (`id` integer PRIMARY KEY AUTOINCREMENT, `name` varchar(255), `rfid_tag` varchar(10), `scan_count` integer, `last_scanned_at` timestamp, signed_in BOOLEAN);
INSERT INTO "users" VALUES(1,'Mike Green','0F0302830D',7,'2010-02-19 15:36:09.443926-0500','f');
INSERT INTO "users" VALUES(2,'Steve Guberman','0415ED345E',13,'2010-02-19 15:36:27.845087-0500','f');
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('users',2);
COMMIT;
