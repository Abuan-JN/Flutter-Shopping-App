-- Security Logs Table Creation
-- This file contains only the security logs table for the admin dashboard

-- Create security logs table for admin dashboard activity tracking
CREATE TABLE IF NOT EXISTS `security_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_type` varchar(50) NOT NULL,
  `description` text,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_ip_address` (`ip_address`),
  CONSTRAINT `security_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `flutter2_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create indexes for better query performance on security logs
CREATE INDEX idx_security_logs_user_time ON `security_logs`(`user_id`, `created_at`);
CREATE INDEX idx_security_logs_event_time ON `security_logs`(`event_type`, `created_at`);
CREATE INDEX idx_security_logs_ip_time ON `security_logs`(`ip_address`, `created_at`);

-- Add a view for recent security events
CREATE VIEW `recent_security_events` AS
SELECT 
    sl.id,
    sl.event_type,
    sl.description,
    sl.user_id,
    u.name as user_name,
    u.email as user_email,
    sl.ip_address,
    sl.created_at,
    CASE 
        WHEN sl.event_type IN ('login_failed', 'login_attempt') THEN 'warning'
        WHEN sl.event_type IN ('login_success', 'logout') THEN 'info'
        WHEN sl.event_type IN ('password_change', 'profile_update') THEN 'success'
        WHEN sl.event_type IN ('suspicious_activity', 'rate_limited') THEN 'danger'
        ELSE 'info'
    END as event_level
FROM `security_logs` sl
LEFT JOIN `flutter2_users` u ON sl.user_id = u.id
ORDER BY sl.created_at DESC
LIMIT 100;