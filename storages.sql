CREATE TABLE `storages`
 ( `citizenid` VARCHAR(255) NOT NULL , `password` VARCHAR(255) NOT NULL , `storagename` VARCHAR(255) NOT NULL ) 
 ENGINE = InnoDB;


ALTER TABLE `storages` ADD COLUMN `storage_size` int NULL DEFAULT 400000 AFTER `storagename`;

ALTER TABLE `storages` ADD COLUMN `holders` text NULL DEFAULT NULL AFTER `storage_size`;

ALTER TABLE `storages` ADD COLUMN `storage_location` VARCHAR(255) NULL DEFAULT NULL AFTER `holders`;

ALTER TABLE `storages` ADD COLUMN `id` int(11) AFTER `holders`;
ALTER TABLE `storages` MODIFY `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
