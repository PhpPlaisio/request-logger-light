/*================================================================================*/
/* DDL SCRIPT                                                                     */
/*================================================================================*/
/*  Title    : ABC-Framework: Request Logger for light websites and development   */
/*  FileName : abc-request-logger-light.ecm                                       */
/*  Platform : MySQL 5.6                                                          */
/*  Version  :                                                                    */
/*  Date     : zaterdag 2 december 2017                                           */
/*================================================================================*/
/*================================================================================*/
/* CREATE TABLES                                                                  */
/*================================================================================*/

CREATE TABLE ABC_REQUEST_LOG (
  rql_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
  cmp_id SMALLINT UNSIGNED,
  pag_id SMALLINT UNSIGNED,
  ses_id INTEGER UNSIGNED,
  usr_id INTEGER UNSIGNED,
  rql_timestamp TIMESTAMP DEFAULT now() NOT NULL,
  rql_request VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_method VARCHAR(8) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_referrer VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_ip INT UNSIGNED,
  rql_host_name VARCHAR(80) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_accept_language VARCHAR(64) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_user_agent VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci,
  rql_status_code SMALLINT,
  rql_number_of_queries INT,
  rql_time FLOAT,
  CONSTRAINT PRIMARY_KEY PRIMARY KEY (rql_id)
);

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_timestamp
The timestamp of the HTTP request
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_request
The requested URL
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_method
The request method used to access the page
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_referrer
The URL of the page which referred the user agent to the page
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_ip
The IP address from which the page is requested
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_accept_language
The accepted languages by the user agent
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_user_agent
The user agent use the request the page
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_status_code
The HTTP status code.
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_number_of_queries
The number of queries executed for processing the page request
*/

/*
COMMENT ON COLUMN ABC_REQUEST_LOG.rql_time
The (real) time required for processing the page request
*/

CREATE TABLE ABC_REQUEST_LOG_COOKIE (
  rql_id INTEGER UNSIGNED NOT NULL,
  rcl_variable VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  rcl_value MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_general_ci
);

CREATE TABLE ABC_REQUEST_LOG_POST (
  rql_id INTEGER UNSIGNED NOT NULL,
  rlp_variable VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  rlp_value MEDIUMTEXT CHARACTER SET utf8 COLLATE utf8_general_ci
);

CREATE TABLE ABC_REQUEST_LOG_QUERY (
  rqq_id INTEGER UNSIGNED AUTO_INCREMENT NOT NULL,
  rql_id INTEGER UNSIGNED NOT NULL,
  rqq_query MEDIUMTEXT NOT NULL,
  rqq_time FLOAT NOT NULL,
  CONSTRAINT PRIMARY_KEY PRIMARY KEY (rqq_id)
);

/*================================================================================*/
/* CREATE INDEXES                                                                 */
/*================================================================================*/

CREATE INDEX IX_FK_ABC_REQUEST_LOG ON ABC_REQUEST_LOG (pag_id);

CREATE INDEX IX_FK_ABC_REQUEST_LOG1 ON ABC_REQUEST_LOG (usr_id);

CREATE INDEX IX_FK_ABC_REQUEST_LOG2 ON ABC_REQUEST_LOG (cmp_id);

CREATE INDEX IX_FK_ABC_REQUEST_LOG3 ON ABC_REQUEST_LOG (ses_id);

CREATE INDEX IX_FK_ABC_REQUEST_LOG_COOKIE ON ABC_REQUEST_LOG_COOKIE (rql_id);

CREATE INDEX rql_id ON ABC_REQUEST_LOG_POST (rql_id);

CREATE INDEX IX_FK_ABC_REQUEST_LOG_QUERY ON ABC_REQUEST_LOG_QUERY (rql_id);
