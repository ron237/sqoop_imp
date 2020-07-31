-------------------------------------------��־------------------------------------------------
CREATE TABLE DW_EXECUTE_LOG 
   (ACCT_MONTH VARCHAR2(16), 
  PKG_NAME VARCHAR2(30), 
  PROCNAME VARCHAR2(100), 
  STARTDATE DATE, 
  ENDDATE DATE, 
  RESULT VARCHAR2(4000), 
  DURATION NUMBER, 
  NOTE VARCHAR2(4000), 
  ROW_COUNT NUMBER, 
  TABLE_NAME VARCHAR2(60)
   );
CREATE TABLE DW_EXECUTE_LOG_HIS 
   (ACCT_MONTH VARCHAR2(16), 
	PKG_NAME VARCHAR2(30), 
	PROCNAME VARCHAR2(100), 
	STARTDATE DATE, 
	ENDDATE DATE, 
	RESULT VARCHAR2(4000), 
	DURATION NUMBER, 
	NOTE VARCHAR2(4000), 
	ROW_COUNT NUMBER, 
	TABLE_NAME VARCHAR2(196), 
	INSERT_DATE DATE
   );   

---------------------------------------------------����--------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE P_INSERT_LOG(
   ACCT_MONTH#  VARCHAR2,
   PKG_NAME#   VARCHAR2,
   PROCNAME#    VARCHAR2,
   STARTDATE#   Date,
   TAB_NAME      Varchar2 Default Null
   ) IS
  /*-------------------------------------------------------------------------------------------
     �� �� �� : ���ɴ洢������־��Ϣ
     ����ʱ�� ��20160105
     �� д �� ��hfhn
     �������� ��
     ִ��ʱ�� : ( ��)
     ʹ�ò��� ��
     �޸ļ�¼ :
  -----------------------------------------------------------------------------------------------*/
   V_TAB_NAME Varchar2(60);
BEGIN

  --��־����, ���ظ�ִ�еĹ��̵���־��¼����־��ʷ����
  INSERT INTO DW_EXECUTE_LOG_HIS
      SELECT A.*, SYSDATE FROM DW_EXECUTE_LOG A
      WHERE ACCT_MONTH = ACCT_MONTH# --AND PKG_NAME=upper(PKG_NAME#)
          AND PROCNAME = upper(PROCNAME#);

  DELETE DW_EXECUTE_LOG
   WHERE ACCT_MONTH = ACCT_MONTH# AND PKG_NAME=upper(PKG_NAME#)
     AND PROCNAME = upper(PROCNAME#);

  V_TAB_NAME := upper(NVL(TAB_NAME, SUBSTR(PROCNAME#,3)));

  INSERT INTO DW_EXECUTE_LOG
    (ACCT_MONTH, PKG_NAME, PROCNAME, STARTDATE ,NOTE, TABLE_NAME)
  VALUES
    (ACCT_MONTH#, upper(PKG_NAME#), upper(PROCNAME#), STARTDATE# ,'��ʼ', V_TAB_NAME);
  COMMIT;

END;

-----------------------------------------------------------------------------END---------------------------------------------------------------------
------------------------------------------------------------------------------����-------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE P_UPDATE_LOG(ACCT_MONTH#    VARCHAR2,
                                         PKGNAME#       VARCHAR2,
                                         PROCNAME#      VARCHAR2,
                                         NOTE#          VARCHAR2,
                                         RESULT#        VARCHAR2,
                                         ENDDATE#       DATE,
                                         ROWLINE#       Number)
IS
  /*-------------------------------------------------------------------------------------------
     �� �� �� : ���´洢������־��Ϣ
     ����ʱ�� ��20160105
     �� д �� ��hfhn
     �������� ��
     ִ��ʱ�� : ( ��)
     ʹ�ò��� ��
     �޸ļ�¼ :
  -----------------------------------------------------------------------------------------------*/
BEGIN
  UPDATE DW_EXECUTE_LOG
     SET ENDDATE  = ENDDATE#,
         RESULT   = RESULT#,
         DURATION = (ENDDATE# - STARTDATE) * 24 * 3600,
         NOTE     = NOTE#,
         ROW_COUNT = ROWLINE#
   WHERE ACCT_MONTH = ACCT_MONTH#
     AND PKG_NAME = PKGNAME#
     AND PROCNAME = PROCNAME#;
  COMMIT;

END;
--------------------------------------------------------------------------------END-----------------------------------------------------------











--=========================================================================HADOOP===================================================================
--==============================hadoop��Ӧoracle��־�� START============================================
CREATE TABLE DW_EXECUTE_LOG_HD
   (ACCT_MONTH VARCHAR2(16), 
  HOUR_ID VARCHAR2(10), 
  MINUTE_ID VARCHAR2(12), 
  PKG_NAME VARCHAR2(30), 
  PROCNAME VARCHAR2(100), 
  PROV_ID  VARCHAR2(10),
  STARTDATE DATE, 
  ENDDATE DATE, 
  RESULT VARCHAR2(4000), 
  DURATION NUMBER, 
  NOTE VARCHAR2(4000), 
  ROW_COUNT NUMBER, 
  TABLE_NAME VARCHAR2(60)
   );  
select * from DW_EXECUTE_LOG_HD; 
 
CREATE TABLE DW_EXECUTE_LOG_HIS_HD 
   (ACCT_MONTH VARCHAR2(16), 
   HOUR_ID VARCHAR2(10), 
   MINUTE_ID VARCHAR2(12), 
   PKG_NAME VARCHAR2(30), 
   PROCNAME VARCHAR2(100), 
   PROV_ID  VARCHAR2(10),
	STARTDATE DATE, 
	ENDDATE DATE, 
	RESULT VARCHAR2(4000), 
	DURATION NUMBER, 
	NOTE VARCHAR2(4000), 
	ROW_COUNT NUMBER, 
	TABLE_NAME VARCHAR2(196), 
	INSERT_DATE DATE
   );
 select * from DW_EXECUTE_LOG_HIS_HD;
--==============================hadoop��Ӧoracle��־�� END================================================
---------------------------------------------------����--------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE P_INSERT_LOG_HD(
   ACCT_MONTH#  VARCHAR2,
   HOUR_ID#  VARCHAR2,
   MINUTE_ID#  VARCHAR2,
   PKG_NAME#   VARCHAR2,
   PROCNAME#    VARCHAR2,
   PROV_ID#  VARCHAR2,
   STARTDATE#   Date,
   TAB_NAME      Varchar2 Default Null
   ) IS
  /*-------------------------------------------------------------------------------------------
     �� �� �� : ���ɴ洢������־��Ϣ
     ����ʱ�� ��20160105
     �� д �� ��hfhn
     �������� ��
     ִ��ʱ�� : ( ��)
     ʹ�ò��� ��
     �޸ļ�¼ :
  -----------------------------------------------------------------------------------------------*/
   V_TAB_NAME Varchar2(60);
BEGIN

  --��־����, ���ظ�ִ�еĹ��̵���־��¼����־��ʷ����
  INSERT INTO DW_EXECUTE_LOG_HIS_HD
      SELECT A.*, SYSDATE FROM DW_EXECUTE_LOG_HD A
      WHERE ACCT_MONTH = ACCT_MONTH# --AND PKG_NAME=upper(PKG_NAME#)
        AND HOUR_ID = HOUR_ID#
        AND MINUTE_ID = MINUTE_ID#
        AND PROV_ID = PROV_ID#
        AND PROCNAME = upper(PROCNAME#);

  DELETE DW_EXECUTE_LOG_HD
   WHERE ACCT_MONTH = ACCT_MONTH# AND PKG_NAME=upper(PKG_NAME#)
     AND HOUR_ID = HOUR_ID#
     AND MINUTE_ID = MINUTE_ID#
     AND PROV_ID = PROV_ID#
     AND PROCNAME = upper(PROCNAME#);

  V_TAB_NAME := upper(NVL(TAB_NAME, SUBSTR(PROCNAME#,3)));

  INSERT INTO DW_EXECUTE_LOG_HD
    (ACCT_MONTH, HOUR_ID,MINUTE_ID,PKG_NAME, PROCNAME, PROV_ID,STARTDATE ,NOTE, TABLE_NAME)
  VALUES
    (ACCT_MONTH#, HOUR_ID#,MINUTE_ID#,upper(PKG_NAME#), upper(PROCNAME#), PROV_ID#,STARTDATE#,'START', V_TAB_NAME);
  COMMIT;

END;

-----------------------------------------------------------------------------END---------------------------------------------------------------------

------------------------------------------------------------------------------����-------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE P_UPDATE_LOG_HD(ACCT_MONTH#    VARCHAR2,
                                         HOUR_ID#       VARCHAR2,
                                         MINUTE_ID#     VARCHAR2,
                                         PKGNAME#       VARCHAR2,
                                         PROCNAME#      VARCHAR2,
                                         PROV_ID#       VARCHAR2,
                                         NOTE#          VARCHAR2,
                                         RESULT#        VARCHAR2,
                                         ENDDATE#       DATE,
                                         ROWLINE#       Number)
IS
  /*-------------------------------------------------------------------------------------------
     �� �� �� : ���´洢������־��Ϣ
     ����ʱ�� ��20160105
     �� д �� ��hfhn
     �������� ��
     ִ��ʱ�� : ( ��)
     ʹ�ò��� ��
     �޸ļ�¼ :
  -----------------------------------------------------------------------------------------------*/
BEGIN
  UPDATE DW_EXECUTE_LOG_HD
     SET ENDDATE  = ENDDATE#,
         RESULT   = RESULT#,
         DURATION = (ENDDATE# - STARTDATE) * 24 * 3600,
         NOTE     = NOTE#,
         ROW_COUNT = ROWLINE#
   WHERE ACCT_MONTH = ACCT_MONTH#
     AND PKG_NAME = UPPER(PKGNAME#)
     AND PROCNAME = UPPER(PROCNAME#)
     AND HOUR_ID = HOUR_ID#
     AND MINUTE_ID = MINUTE_ID#
     AND PROV_ID = PROV_ID#;
  COMMIT;

END;
--------------------------------------------------------------------------------END-----------------------------------------------------------

