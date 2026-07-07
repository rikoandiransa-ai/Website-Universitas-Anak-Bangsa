-- =======================================================
-- WEB-BASED CAMPUS ACTIVITY SYSTEM DATABASE SCHEMA
-- Target Database: MySQL 8.0+
-- Prepared for: UNIVERSITAS ANAK BANGSA (UNABA)
-- =======================================================

-- Create Database if not exists
CREATE DATABASE IF NOT EXISTS unaba_campus_activity;
USE unaba_campus_activity;

-- -------------------------------------------------------
-- Table: users
-- Stores credential info for admins and overall users
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` VARCHAR(50) NOT NULL,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `role` VARCHAR(20) NOT NULL DEFAULT 'student',
  PRIMARY KEY (`id`),
  INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- Table: students
-- Stores detailed profile of students with bcrypt passwords
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `students` (
  `id` VARCHAR(50) NOT NULL, -- NIM / Student ID
  `name` VARCHAR(100) NOT NULL,
  `study_program` VARCHAR(100) NOT NULL,
  `faculty` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL, -- BCrypt encrypted string
  PRIMARY KEY (`id`),
  INDEX `idx_students_username` (`username`),
  INDEX `idx_students_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- Table: activities
-- Stores campus event details
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `activities` (
  `id` VARCHAR(50) NOT NULL,
  `activity_name` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `date` DATE NOT NULL,
  `time` TIME NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `organizer` VARCHAR(255) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'Active', -- 'Active', 'Completed'
  PRIMARY KEY (`id`),
  INDEX `idx_activity_date` (`date`),
  INDEX `idx_activity_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- Table: absences (Student Attendance Logs)
-- Tracks attendance with referential actions (Cascade Delete)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS `absences` (
  `id` VARCHAR(50) NOT NULL,
  `student_id` VARCHAR(50) NOT NULL,
  `activity_id` VARCHAR(50) NOT NULL,
  `date` DATE NOT NULL,
  `time` TIME NOT NULL, -- manual log time
  `status` VARCHAR(20) NOT NULL DEFAULT 'Present', -- 'Present', 'Sick', 'Permission', 'Absent'
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_absences_student` 
    FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_absences_activity` 
    FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `idx_absences_date` (`date`),
  INDEX `idx_absences_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- -------------------------------------------------------
-- SEED DATA (DUMMY DATA)
-- -------------------------------------------------------

-- 1. Insert User Admin
-- In our Node Express application, password comparisons for "Admin"
-- are intercepted and matched with 'unaba123'
INSERT INTO `users` (`id`, `username`, `role`) VALUES 
('1', 'Admin', 'admin')
ON DUPLICATE KEY UPDATE `username`=`username`;

-- 2. Insert Students
-- Passwords are hashed with bcrypt (salt rounds = 10) for 'student123'
INSERT INTO `students` (`id`, `name`, `study_program`, `faculty`, `email`, `username`, `password`) VALUES
('NIM1001', 'Riko Andiransa', 'Informatics Engineering', 'Computer Science', 'riko@unaba.ac.id', 'riko', '$2a$10$3Y8.YAtXit06g8BwB7r8Xuk0H9mG8T97iU8pSoxC3C4uA0YfevXjS'),
('NIM1002', 'Aditya Pratama', 'Information Systems', 'Computer Science', 'aditya@unaba.ac.id', 'aditya', '$2a$10$3Y8.YAtXit06g8BwB7r8Xuk0H9mG8T97iU8pSoxC3C4uA0YfevXjS'),
('NIM1003', 'Siti Rahma', 'Digital Business', 'Economics & Business', 'siti@unaba.ac.id', 'siti', '$2a$10$3Y8.YAtXit06g8BwB7r8Xuk0H9mG8T97iU8pSoxC3C4uA0YfevXjS'),
('NIM1004', 'Budi Santoso', 'Management', 'Economics & Business', 'budi@unaba.ac.id', 'budi', '$2a$10$3Y8.YAtXit06g8BwB7r8Xuk0H9mG8T97iU8pSoxC3C4uA0YfevXjS'),
('NIM1005', 'Dewi Lestari', 'Visual Communication Design', 'Creative Industry', 'dewi@unaba.ac.id', 'dewi', '$2a$10$3Y8.YAtXit06g8BwB7r8Xuk0H9mG8T97iU8pSoxC3C4uA0YfevXjS')
ON DUPLICATE KEY UPDATE `name`=`name`;

-- 3. Insert Activities
INSERT INTO `activities` (`id`, `activity_name`, `description`, `date`, `time`, `location`, `organizer`, `status`) VALUES
('ACT001', 'Campus Hackathon 2026', 'A 24-hour programming and design competition to solve real-world problems.', '2026-07-15', '09:00:00', 'Auditorium Main Campus', 'Tech Student Association', 'Active'),
('ACT002', 'Entrepreneurship Seminar', 'Seminar featuring modern digital startups and business builders in Indonesia.', '2026-07-20', '13:00:00', 'Seminar Hall B, 3rd Floor', 'BEM Universitas Anak Bangsa', 'Active'),
('ACT003', 'English Debate Championship', 'Annual inter-faculty english debate competition covering current global trends.', '2026-07-10', '08:00:00', 'Classroom C.402', 'English Club UNABA', 'Active'),
('ACT004', 'Campus Blood Donation Drive', 'Quarterly community service in partnership with Indonesian Red Cross (PMI).', '2026-07-05', '08:30:00', 'Campus Gymnasium', 'KSR PMI Sub-Unit UNABA', 'Completed'),
('ACT005', 'Web Development Bootcamp', 'Intensive weekend hands-on coding course focusing on React & Tailwind CSS.', '2026-07-01', '10:00:00', 'Lab Computer 2', 'Informatics Lab', 'Completed')
ON DUPLICATE KEY UPDATE `activity_name`=`activity_name`;

-- 4. Insert Absences
INSERT INTO `absences` (`id`, `student_id`, `activity_id`, `date`, `time`, `status`) VALUES
('ABS001', 'NIM1001', 'ACT001', '2026-07-15', '09:15:00', 'Present'),
('ABS002', 'NIM1002', 'ACT001', '2026-07-15', '09:10:00', 'Present'),
('ABS003', 'NIM1003', 'ACT001', '2026-07-15', '09:30:00', 'Present'),
('ABS004', 'NIM1004', 'ACT001', '2026-07-15', '10:00:00', 'Absent'),
('ABS005', 'NIM1005', 'ACT001', '2026-07-15', '09:05:00', 'Present'),
('ABS006', 'NIM1001', 'ACT002', '2026-07-20', '13:05:00', 'Present'),
('ABS007', 'NIM1002', 'ACT002', '2026-07-20', '13:10:00', 'Present'),
('ABS008', 'NIM1003', 'ACT002', '2026-07-20', '13:40:00', 'Sick'),
('ABS009', 'NIM1004', 'ACT002', '2026-07-20', '13:00:00', 'Present'),
('ABS010', 'NIM1001', 'ACT005', '2026-07-01', '10:02:00', 'Present'),
('ABS011', 'NIM1002', 'ACT005', '2026-07-01', '10:15:00', 'Present'),
('ABS012', 'NIM1005', 'ACT005', '2026-07-01', '10:05:00', 'Present'),
('ABS013', 'NIM1003', 'ACT005', '2026-07-01', '09:55:00', 'Permission'),
('ABS014', 'NIM1004', 'ACT005', '2026-07-01', '10:30:00', 'Absent')
ON DUPLICATE KEY UPDATE `status`=`status`;
