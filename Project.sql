DROP TABLE RANKLIST;
DROP TABLE VERDICT;
DROP TABLE PROBLEMS;
DROP TABLE CONTESTANT;
DROP TABLE CONTEST;

CREATE TABLE CONTESTANT
(
	USER_ID NUMBER(5),
	USER_NAME VARCHAR(30) NOT NULL,
	PASSWORD VARCHAR(10),
	GENDER VARCHAR(10) DEFAULT 'MALE',
	LANGUAGE VARCHAR(10)
);


CREATE TABLE CONTEST
(
	CONTEST_ID NUMBER(5),
	CONTEST_NAME VARCHAR(30) NOT NULL,
	DURATION NUMBER
);


CREATE TABLE PROBLEMS
(
	PROBLEM_ID NUMBER(5),
	PROBLM_NAME VARCHAR(30) NULL,
	SCORE NUMBER(4) NOT NULL,
	CONTEST_ID NUMBER(5)
);


CREATE TABLE VERDICT
(
	SUBMISSION_ID NUMBER(10),
	PROBLEM_ID NUMBER(5),
	VERDICT NUMBER(1) NOT NULL CHECK(VERDICT>-1 AND VERDICT <2),
	USER_ID NUMBER(5)
);


CREATE TABLE RANKLIST
(
	USER_ID NUMBER(5),
	CONTEST_ID NUMBER(5),
	FINAL_SCORE NUMBER(5)
);

---------------------------------PRIMARY KEY---------------------------------------
ALTER TABLE CONTESTANT ADD CONSTRAINT PK_CONTESTANT_USER_ID PRIMARY KEY(USER_ID);
ALTER TABLE CONTEST ADD CONSTRAINT PK_CONTEST_CONTEST_ID PRIMARY KEY(CONTEST_ID);
ALTER TABLE PROBLEMS ADD CONSTRAINT PK_PROBLEMS_PROBLEM_ID PRIMARY KEY(PROBLEM_ID);
ALTER TABLE VERDICT ADD CONSTRAINT PK_VERDICT_SUBMISSION_ID PRIMARY KEY(SUBMISSION_ID);
--------------------------------------------------------------------------------------------------

---------------------------------DROP CONSTRAINT-----------------------------------
ALTER TABLE CONTESTANT DROP CONSTRAINT PK_CONTESTANT_USER_ID;
ALTER TABLE CONTESTANT ADD CONSTRAINT PK_CONTESTANT_USER_ID PRIMARY KEY(USER_ID);
----------------------------------------------------------------------------------


---------------------------------FOREIGN KEY------------------------------------------------------
ALTER TABLE PROBLEMS ADD CONSTRAINT FK_PROBLEMS_CONTEST_ID FOREIGN KEY(CONTEST_ID) REFERENCES CONTEST(CONTEST_ID) ON DELETE CASCADE;
ALTER TABLE VERDICT ADD CONSTRAINT FK_VERDICT_USER_ID FOREIGN KEY(USER_ID) REFERENCES CONTESTANT(USER_ID) ON DELETE CASCADE;
ALTER TABLE VERDICT ADD CONSTRAINT FK_VERDICT_PROBLEM_ID FOREIGN KEY(PROBLEM_ID) REFERENCES PROBLEMS(PROBLEM_ID) ON DELETE CASCADE;
ALTER TABLE RANKLIST ADD CONSTRAINT FK_RANKLIST_USER_ID FOREIGN KEY (USER_ID) REFERENCES CONTESTANT(USER_ID) ON DELETE CASCADE;
ALTER TABLE RANKLIST ADD CONSTRAINT FK_RANKLIST_CONTEST_ID FOREIGN KEY (CONTEST_ID) REFERENCES CONTEST(CONTEST_ID) ON DELETE CASCADE;
----------------------------------------------------------------------------------------------------

---------------------------------DESCRIBE TABLES-----------------------------------
DESCRIBE CONTESTANT;
DESCRIBE CONTEST;
DESCRIBE PROBLEMS;
DESCRIBE VERDICT;
DESCRIBE RANKLIST;
------------------------------------------------------------------------------------


--------------------------------ALTER--------------------------------------
ALTER TABLE CONTESTANT
	ADD AGE NUMBER(2) CHECK (AGE > 0 AND AGE < 100);
ALTER TABLE CONTESTANT
	MODIFY AGE NUMBER(3);
ALTER TABLE CONTESTANT
	RENAME COLUMN AGE to USER_AGE;
DESCRIBE CONTESTANT;
ALTER TABLE CONTESTANT
	DROP COLUMN USER_AGE;
----------------------------------------------------------------------------

----------------------------INSERTION---------------------------------------

-------------------------------------------------PROCEDURES----------------------------

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE UPDATE_RANKLIST(TEMP_USER_ID RANKLIST.USER_ID%TYPE, TEMP_CONTEST_ID PROBLEMS.CONTEST_ID%TYPE, NEW_SCORE RANKLIST.FINAL_SCORE%TYPE) IS
   TEMP_SCROE RANKLIST.FINAL_SCORE%TYPE;
   IS_AVAILABLE NUMBER:=0;
BEGIN

	SELECT COUNT(USER_ID) INTO IS_AVAILABLE FROM RANKLIST
	WHERE USER_ID=TEMP_USER_ID AND CONTEST_ID = TEMP_CONTEST_ID;

	IF IS_AVAILABLE=0 THEN
		INSERT INTO RANKLIST(USER_ID,CONTEST_ID,FINAL_SCORE) VALUES(TEMP_USER_ID,TEMP_CONTEST_ID,0);
  	END IF;

    SELECT FINAL_SCORE INTO TEMP_SCROE FROM RANKLIST
    WHERE USER_ID=TEMP_USER_ID AND CONTEST_ID=TEMP_CONTEST_ID;
    UPDATE RANKLIST SET FINAL_SCORE=TEMP_SCROE+NEW_SCORE WHERE USER_ID=TEMP_USER_ID AND CONTEST_ID=TEMP_CONTEST_ID;
END;
/
SHOW ERRORS;

------------------------------------------------TRIGGERS----------------------------------
SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER MAKE_RANKLIST AFTER INSERT OR UPDATE ON VERDICT
FOR EACH ROW
DECLARE
TEMP_SCROE PROBLEMS.SCORE%TYPE;
TEMP_CONTEST_ID PROBLEMS.CONTEST_ID%TYPE;
TEMP_USER_ID RANKLIST.USER_ID%TYPE;
BEGIN
	SELECT CONTEST_ID INTO TEMP_CONTEST_ID FROM PROBLEMS WHERE PROBLEM_ID=:NEW.PROBLEM_ID;
	SELECT SCORE INTO TEMP_SCROE FROM PROBLEMS WHERE PROBLEM_ID=:NEW.PROBLEM_ID;
	TEMP_USER_ID:= :NEW.USER_ID;
  IF :NEW.VERDICT=1 THEN
  	UPDATE_RANKLIST(TEMP_USER_ID,TEMP_CONTEST_ID,TEMP_SCROE);
  END IF;
END;
/
SHOW ERRORS;
----------------------------------------------------------------------------------------------

----------------------CREATE USER-----------------------------------------
INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(1,'TOURIST','1234','MALE','C++');

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(2,'PETR','1235','MALE','JAVA');

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(3,'SADIA NAHREN','1236','FEMALE','PYTHON');
------------------------------------------------------------------------

----------------------ADD CONTEST----------------------------------------
INSERT INTO CONTEST(CONTEST_ID, CONTEST_NAME, DURATION)
VALUES(1,'CODEFORCES ROUND 1',120);

INSERT INTO CONTEST(CONTEST_ID, CONTEST_NAME, DURATION)
VALUES(2,'TOPCODER ROUND 1',75);
-------------------------------------------------------------------------


----------------------ADD PROBLEMS--------------------------------------
INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(101,'3N+1 PROBLEM',100,1);

INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(102,'SEGMENT TREE QUERY',100,1);

INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(103,'MAXIMUM FLOW',100,1);

INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(104,'SQUARE ROOT SEGMENTATION',100,2);

INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(105,'SLIDING WINDOW',500,2);

INSERT INTO PROBLEMS(PROBLEM_ID, PROBLM_NAME, SCORE, CONTEST_ID)
VALUES(106,'SEARCH THE ROOT',800,2);
---------------------------------------------------------------------

----------------------ADD SUBMISSIONS---------------------------------
INSERT INTO VERDICT(SUBMISSION_ID, PROBLEM_ID, VERDICT, USER_ID)
VALUES(1001,101,0,1);

INSERT INTO VERDICT(SUBMISSION_ID, PROBLEM_ID, VERDICT, USER_ID)
VALUES(1002,101,1,1);

INSERT INTO VERDICT(SUBMISSION_ID, PROBLEM_ID, VERDICT, USER_ID)
VALUES(1003,102,1,2);

INSERT INTO VERDICT(SUBMISSION_ID, PROBLEM_ID, VERDICT, USER_ID)
VALUES(1004,103,1,3);

INSERT INTO VERDICT(SUBMISSION_ID, PROBLEM_ID, VERDICT, USER_ID)
VALUES(1005,101,1,3);
---------------------------------------------------------------------

---------------------CREATING RANKLIST-------------------------------
-- INSERT INTO RANKLIST(USER_ID, CONTEST_ID, FINAL_SCORE)
-- VALUES(1,1,50);

-- INSERT INTO RANKLIST(USER_ID, CONTEST_ID, FINAL_SCORE)
-- VALUES(2,1,100);

-- INSERT INTO RANKLIST(USER_ID, CONTEST_ID, FINAL_SCORE)
-- VALUES(3,1,90);
----------------------------------------------------------------------


-----------------------------UPDATE-----------------------------------
UPDATE PROBLEMS SET SCORE= 1000 WHERE PROBLEM_ID = 106;
SELECT * FROM PROBLEMS;
UPDATE PROBLEMS SET SCORE= 800 WHERE PROBLEM_ID = 106;
SELECT * FROM PROBLEMS;
UPDATE PROBLEMS SET SCORE= 1200 WHERE PROBLEM_ID = 106;
SELECT * FROM PROBLEMS;
UPDATE PROBLEMS SET SCORE= 800 WHERE PROBLEM_ID = 106;
SELECT * FROM PROBLEMS;
----------------------------------------------------------------------

COMMIT;

-----------------------------SHOW ALL CONTESTANT----------------------
SELECT * FROM CONTESTANT;
SELECT USER_NAME FROM CONTESTANT WHERE LANGUAGE='C++';
SELECT USER_ID,USER_NAME,LANGUAGE FROM CONTESTANT WHERE GENDER='FEMALE';
-----------------------------------------------------------------------

----------------------------SHOW PROBLEMS OF AN INDIVIDUAL CONTEST------------
SELECT * FROM PROBLEMS
WHERE CONTEST_ID=2;

SELECT * FROM PROBLEMS
WHERE CONTEST_ID=1;
------------------------------------------------------------------------------

-------------------SHOW ALL SUBMISSION HISTORY OF CONTEST 1------------------
SELECT * FROM VERDICT
WHERE PROBLEM_ID IN ( SELECT PROBLEM_ID FROM PROBLEMS
	WHERE CONTEST_ID =1
);
----------------------------------------------------------------------------

------------------------------JOIN------------------------------------------
SELECT PROBLM_NAME, USER_NAME AS "CONTESTANT", VERDICT FROM ((VERDICT T1 JOIN PROBLEMS T2 ON T1.PROBLEM_ID = T2.PROBLEM_ID AND T2.CONTEST_ID=1)
JOIN CONTESTANT T3 ON T1.USER_ID=T3.USER_ID);

SELECT CONTEST_NAME AS "CONTEST", PROBLM_NAME AS "PROBLEM", SCORE FROM (CONTEST T1 JOIN PROBLEMS T2 ON T1.CONTEST_ID = T2.CONTEST_ID);
----------------------------------------------------------------------------

------------------------------SEARCH---------------------------------------
SELECT * FROM CONTEST WHERE CONTEST_NAME LIKE '%CODEF%';
SELECT * FROM PROBLEMS WHERE PROBLM_NAME LIKE '%FLOW%';
---------------------------------------------------------------------------

-----------------------------------------------------CURSOR---------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
     CURSOR USER_CUR IS SELECT USER_NAME, USER_ID, LANGUAGE FROM CONTESTANT;
     TEMP_ROW USER_CUR%ROWTYPE;
     NO_OF_ELEMENT NUMBER;
BEGIN
SELECT COUNT(USER_ID) INTO NO_OF_ELEMENT FROM CONTESTANT;
DBMS_OUTPUT.PUT_LINE('CURRENT USER IS : ');
OPEN USER_CUR;
      LOOP
        FETCH USER_CUR INTO TEMP_ROW;
		DBMS_OUTPUT.PUT_LINE('USER : ' || TEMP_ROW.USER_NAME || ' USER ID : ' || TEMP_ROW.USER_ID || ' LANGUAGE : '|| TEMP_ROW.LANGUAGE);
        EXIT WHEN USER_CUR%ROWCOUNT >NO_OF_ELEMENT-1;
      END LOOP;
CLOSE USER_CUR;
END;
/


-------------------------------------------------LOOP---------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
	I NUMBER(5):=0;
   NO_OF_ELEMENT  NUMBER(10) := 0;
   NAME       CONTESTANT.USER_NAME%TYPE;
   USER_GENDER CONTESTANT.GENDER%TYPE;

BEGIN
	SELECT COUNT(USER_ID) INTO NO_OF_ELEMENT FROM CONTESTANT;
	DBMS_OUTPUT.PUT_LINE('CONTESTANT INFORMATIONS :');
	DBMS_OUTPUT.PUT_LINE('#########################');
   FOR I IN 1..NO_OF_ELEMENT
   LOOP
      SELECT USER_NAME, GENDER
      INTO NAME,USER_GENDER
      FROM CONTESTANT WHERE USER_ID=I;

      DBMS_OUTPUT.PUT_LINE ('CONTESTANT NO :' || I);
      DBMS_OUTPUT.PUT_LINE ('USER_NAME : ' || NAME);
      DBMS_OUTPUT.PUT_LINE ('GENDER :' || USER_GENDER);
      DBMS_OUTPUT.PUT_LINE ('------------------------------------------------');
   END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE (SQLERRM);
END;
/
------------------------------------------------------------------------------------------------------

-------------------------------------------------PROCEDURES----------------------------

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SHOW_RANKLIST(TEMP_CONTEST_ID RANKLIST.CONTEST_ID%TYPE) IS

CURSOR USER_CUR IS SELECT T1.USER_ID,T1.USER_NAME,T2.FINAL_SCORE FROM (CONTESTANT T1 JOIN RANKLIST T2 ON T1.USER_ID=T2.USER_ID) ORDER BY T2.FINAL_SCORE DESC;
TEMP_ROW USER_CUR%ROWTYPE;
NO_OF_ELEMENT NUMBER;
TEMP_CONTST_NAME CONTEST.CONTEST_NAME%TYPE;
BEGIN
	SELECT COUNT(USER_ID) INTO NO_OF_ELEMENT FROM RANKLIST WHERE CONTEST_ID=TEMP_CONTEST_ID;
	SELECT CONTEST_NAME INTO TEMP_CONTST_NAME FROM CONTEST WHERE CONTEST_ID=TEMP_CONTEST_ID;
OPEN USER_CUR;
		DBMS_OUTPUT.PUT_LINE('FINAL RANKLIST OF ' ||TEMP_CONTST_NAME || ':');
		DBMS_OUTPUT.PUT_LINE('##############################################################################');
      LOOP
        FETCH USER_CUR INTO TEMP_ROW;
		DBMS_OUTPUT.PUT_LINE( 'USER ID = '||TEMP_ROW.USER_ID || '     ' || 'NAME = '||TEMP_ROW.USER_NAME || '                    '|| 'FINAL SCORE = '||TEMP_ROW.FINAL_SCORE);
        EXIT WHEN USER_CUR%ROWCOUNT >NO_OF_ELEMENT-1;
      END LOOP;
CLOSE USER_CUR;

END;
/
SHOW ERRORS;

SELECT * FROM RANKLIST;

BEGIN
SHOW_RANKLIST(1);
END;
/


COMMIT;

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(4,'Shovo','MAKRU','MALE','C');

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(5,'Sourav','12345','MALE','C++');

COMMIT;

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(6,'Shanto','12367','MALE','PYTHON');
SELECT * FROM CONTESTANT;
SAVEPOINT P1;

INSERT INTO CONTESTANT(USER_ID, USER_NAME, PASSWORD, GENDER, LANGUAGE)
VALUES(7,'Badhon','123678','MALE','PEARL');
SELECT * FROM CONTESTANT;
ROLLBACK TO P1;
SELECT * FROM CONTESTANT;
ROLLBACK;
SELECT * FROM CONTESTANT;

SELECT T1.USER_ID, T1.USER_NAME AS "NAME", T2.FINAL_SCORE FROM (CONTESTANT T1 JOIN RANKLIST T2 ON T1.USER_ID=T2.USER_ID AND T2.CONTEST_ID=1)
ORDER BY T2.FINAL_SCORE DESC;
