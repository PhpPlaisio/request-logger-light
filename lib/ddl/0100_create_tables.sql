/*================================================================================*/
/* DDL SCRIPT                                                                     */
/*================================================================================*/
/*  Title    : ABC Request Logger Light                                           */
/*  FileName : abc-request-logger-light.ecm                                       */
/*  Platform : MySQL 5.6                                                          */
/*  Version  : 1.0.0                                                              */
/*  Date     : donderdag 20 april 2017                                            */
/*================================================================================*/
/*================================================================================*/
/* CREATE TABLES                                                                  */
/*================================================================================*/

CREATE TABLE LOG_REQUEST (
  rql_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
  cmp_id SMALLINT UNSIGNED NOT NULL,
  pag_id SMALLINT UNSIGNED,
  ses_id INTEGER UNSIGNED,
  usr_id INTEGER UNSIGNED NOT NULL,
  rql_datetime DATETIME NOT NULL,
  rql_request VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_method VARCHAR(8) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_referrer VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_ip INT,
  rql_host_name VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_accept_language VARCHAR(64) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_user_agent VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_number_of_queries INT,
  rql_time FLOAT,
  rql_size INT,
  CONSTRAINT PRIMARY_KEY PRIMARY KEY (rql_id)
);

/*
COMMENT ON COLUMN LOG_REQUEST.rql_datetime
The date and time of the HTTP request
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_request
The requested URL
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_method
The request method used to access the page
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_referrer
The URL of the page which referred the user agent to the page
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_ip
The IP address from which the page is requested
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_accept_language
The accepted languages by the user agent
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_user_agent
The user agent use the request the page
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_number_of_queries
The number of queries executed for processing the page request
*/

/*
COMMENT ON COLUMN LOG_REQUEST.rql_time
The (real)time required for processing the page request
*/

CREATE TABLE LOG_REQUEST_COOKIE (
  rql_id INTEGER UNSIGNED NOT NULL,
  rcl_variable VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  rcl_value MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_general_ci
);

CREATE TABLE LOG_REQUEST_POST (
  rql_id INTEGER UNSIGNED NOT NULL,
  rlp_variable VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  rlp_value MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_general_ci
);

CREATE TABLE LOG_REQUEST_QUERY (
  rqq_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
  rql_id INTEGER NOT NULL,
  rqq_query MEDIUMBLOB NOT NULL,
  rqq_time FLOAT NOT NULL,
  CONSTRAINT PRIMARY_KEY PRIMARY KEY (rqq_id)
);

/*================================================================================*/
/* CREATE INDEXES                                                                 */
/*================================================================================*/

CREATE INDEX IX_FK_LOG_REQUEST ON LOG_REQUEST (pag_id);

CREATE INDEX IX_FK_LOG_REQUEST1 ON LOG_REQUEST (usr_id);

CREATE INDEX IX_FK_LOG_REQUEST2 ON LOG_REQUEST (cmp_id);

CREATE INDEX IX_FK_LOG_REQUEST3 ON LOG_REQUEST (ses_id);

CREATE INDEX IX_FK_LOG_REQUEST_COOKIE ON LOG_REQUEST_COOKIE (rql_id);

CREATE INDEX rql_id ON LOG_REQUEST_POST (rql_id);

CREATE INDEX IX_FK_LOG_REQUEST_QUERY ON LOG_REQUEST_QUERY (rql_id);

/*================================================================================*/
/* CREATE FOREIGN KEYS                                                            */
/*================================================================================*/

ALTER TABLE LOG_REQUEST_COOKIE
  ADD CONSTRAINT FK_LOG_REQUEST_COOKIE_LOG_REQUEST
  FOREIGN KEY (rql_id) REFERENCES LOG_REQUEST (rql_id);

ALTER TABLE LOG_REQUEST_POST
  ADD CONSTRAINT FK_LOG_REQUEST_POST_LOG_REQUEST
  FOREIGN KEY (rql_id) REFERENCES LOG_REQUEST (rql_id);

ALTER TABLE LOG_REQUEST_QUERY
  ADD CONSTRAINT FK_LOG_REQUEST_QUERY_LOG_REQUEST
  FOREIGN KEY (rql_id) REFERENCES LOG_REQUEST (rql_id);
