BEGIN
  FOR t IN (
    SELECT table_name
    FROM user_tables
    WHERE table_name IN (
      'HACKATHON_WINNERS','EVALUATION_SCORES','TEAM_MEMBERS','HACKATHON_TEAMS',
      'HACKATHON_USERS','EVALUATIONS','PROJECTS','TEAMS','JUDGES','PARTICIPANTS',
      'ORGANIZERS','USERS','HACKATHONS','COMPETES_IN','SCORES','MEMBER_OF','ORGANIZES'
    )
  ) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

-- ========== TABLE CREATION ==========

-- Users Table
CREATE TABLE users (
  id       NUMBER PRIMARY KEY,
  name     VARCHAR2(100),
  email    VARCHAR2(100),
  password VARCHAR2(100),
  role     VARCHAR2(20) -- 'judge', 'organizer', 'participant'
);

-- Role-specific Tables
CREATE TABLE judges (
  user_id NUMBER PRIMARY KEY REFERENCES users(id)
);

CREATE TABLE organizers (
  user_id NUMBER PRIMARY KEY REFERENCES users(id)
);

CREATE TABLE participants (
  user_id NUMBER PRIMARY KEY REFERENCES users(id)
);

-- Hackathons Table
CREATE TABLE hackathons (
  id          NUMBER PRIMARY KEY,
  name        VARCHAR2(100),
  location    VARCHAR2(100),
  start_date  DATE,
  end_date    DATE
);

-- Teams Table
CREATE TABLE teams (
  id   NUMBER PRIMARY KEY,
  name VARCHAR2(100)
);

-- Member Of Table
CREATE TABLE member_of (
  user_id NUMBER REFERENCES users(id),
  team_id NUMBER REFERENCES teams(id),
  PRIMARY KEY (user_id)
);

-- Projects Table
CREATE TABLE projects (
  id            NUMBER PRIMARY KEY,
  team_id       NUMBER REFERENCES teams(id),
  hackathon_id  NUMBER REFERENCES hackathons(id),
  title         VARCHAR2(100),
  description   VARCHAR2(300),
  submission_url VARCHAR2(300)
);

-- Evaluations Table
CREATE TABLE evaluations (
  judge_id          NUMBER REFERENCES users(id),
  project_id        NUMBER REFERENCES projects(id),
  ideation          NUMBER,
  implementation    NUMBER,
  team_dynamics     NUMBER,
  usp_differentiation NUMBER,
  PRIMARY KEY (judge_id, project_id)
);

-- ========== INSERT PROCEDURES ==========

-- Users
CREATE OR REPLACE PROCEDURE insert_user (
  uid   NUMBER, uname VARCHAR2, uemail VARCHAR2, upass VARCHAR2, urole VARCHAR2
) IS BEGIN
  INSERT INTO users VALUES (uid, uname, uemail, upass, urole);
  COMMIT;
END;
/
-- Judges
CREATE OR REPLACE PROCEDURE insert_judge(jid NUMBER) IS BEGIN
  INSERT INTO judges VALUES (jid); COMMIT;
END;
/
-- Organizers
CREATE OR REPLACE PROCEDURE insert_organizer(oid NUMBER) IS BEGIN
  INSERT INTO organizers VALUES (oid); COMMIT;
END;
/
-- Participants
CREATE OR REPLACE PROCEDURE insert_participant(pid NUMBER) IS BEGIN
  INSERT INTO participants VALUES (pid); COMMIT;
END;
/
-- Hackathons
CREATE OR REPLACE PROCEDURE insert_hackathon (
  hid NUMBER, hname VARCHAR2, hloc VARCHAR2, hstart DATE, hend DATE
) IS BEGIN
  INSERT INTO hackathons VALUES (hid, hname, hloc, hstart, hend);
  COMMIT;
END;
/
-- Teams
CREATE OR REPLACE PROCEDURE insert_team (
  tid NUMBER, tname VARCHAR2
) IS BEGIN
  INSERT INTO teams VALUES (tid, tname);
  COMMIT;
END;
/
-- Member Of
CREATE OR REPLACE PROCEDURE insert_team_member (
  uid NUMBER, tid NUMBER
) IS BEGIN
  INSERT INTO member_of VALUES (uid, tid);
  COMMIT;
END;
/
-- Projects
CREATE OR REPLACE PROCEDURE insert_project (
  pid NUMBER, tid NUMBER, hid NUMBER, ptitle VARCHAR2, pdesc VARCHAR2, purl VARCHAR2
) IS BEGIN
  INSERT INTO projects VALUES (pid, tid, hid, ptitle, pdesc, purl);
  COMMIT;
END;
/
-- Evaluations
CREATE OR REPLACE PROCEDURE insert_evaluation (
  jid NUMBER, pid NUMBER, idea NUMBER, impl NUMBER, teamdyn NUMBER, usp NUMBER
) IS BEGIN
  INSERT INTO evaluations VALUES (jid, pid, idea, impl, teamdyn, usp);
  COMMIT;
END;
/
-- ========== DATA INSERTION ==========

BEGIN
  -- Judges (1–4)
  insert_user(1, 'Judge A', 'judgeA@mail.com', 'pass1', 'judge');
  insert_user(2, 'Judge B', 'judgeB@mail.com', 'pass2', 'judge');
  insert_user(3, 'Judge C', 'judgeC@mail.com', 'pass3', 'judge');
  insert_user(4, 'Judge D', 'judgeD@mail.com', 'pass4', 'judge');
  insert_judge(1); insert_judge(2); insert_judge(3); insert_judge(4);

  -- Organizers (5–6)
  insert_user(5, 'Organizer X', 'orgX@mail.com', 'org1', 'organizer');
  insert_user(6, 'Organizer Y', 'orgY@mail.com', 'org2', 'organizer');
  insert_organizer(5); insert_organizer(6);

  -- Participants (7–26)
  FOR i IN 7..26 LOOP
    insert_user(i, 'Participant_'||i, 'p'||i||'@mail.com', 'p'||i||'pwd', 'participant');
    insert_participant(i);
  END LOOP;

  -- Hackathon
  insert_hackathon(101, 'CodeBlitz', 'Delhi', TO_DATE('2025-06-01','YYYY-MM-DD'), TO_DATE('2025-06-03','YYYY-MM-DD'));

  -- Teams
  insert_team(1, 'Alpha Warriors');
  insert_team(2, 'Beta Bytes');
  insert_team(3, 'Cyber Ninjas');
  insert_team(4, 'Code Crushers');

  -- Team Members
  insert_team_member(7, 1); insert_team_member(8, 1); insert_team_member(9, 1); insert_team_member(10, 1); insert_team_member(11, 1);
  insert_team_member(12, 2); insert_team_member(13, 2); insert_team_member(14, 2); insert_team_member(15, 2); insert_team_member(16, 2);
  insert_team_member(17, 3); insert_team_member(18, 3); insert_team_member(19, 3); insert_team_member(20, 3); insert_team_member(21, 3);
  insert_team_member(22, 4); insert_team_member(23, 4); insert_team_member(24, 4); insert_team_member(25, 4); insert_team_member(26, 4);

  -- Projects with URL (submission)
  insert_project(301, 1, 101, 'SmartBin', 'IoT waste management system', 'https://github.com/team1/smartbin');
  insert_project(302, 2, 101, 'MedAssist', 'AI assistant for hospitals', 'https://github.com/team2/medassist');
  insert_project(303, 3, 101, 'AgroTrack', 'Smart farming platform', 'https://github.com/team3/agrotrack');
  insert_project(304, 4, 101, 'EduFlex', 'Learning management solution', 'https://github.com/team4/eduflex');

  -- Evaluations: 4 judges × 4 projects
  FOR j IN 1..4 LOOP
    FOR p IN 301..304 LOOP
      insert_evaluation(
        j, p,
        TRUNC(DBMS_RANDOM.VALUE(70, 100)),
        TRUNC(DBMS_RANDOM.VALUE(70, 100)),
        TRUNC(DBMS_RANDOM.VALUE(70, 100)),
        TRUNC(DBMS_RANDOM.VALUE(70, 100))
      );
    END LOOP;
  END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE declare_winner IS
  v_project_title   VARCHAR2(100);
  v_team_name       VARCHAR2(100);
  v_score           NUMBER;
BEGIN
  SELECT title, t.name, SUM(ideation + implementation + team_dynamics + usp_differentiation)
  INTO v_project_title, v_team_name, v_score
  FROM projects p
  JOIN teams t ON p.team_id = t.id
  JOIN evaluations e ON p.id = e.project_id
  GROUP BY p.id, title, t.name
  HAVING SUM(ideation + implementation + team_dynamics + usp_differentiation) = (
    SELECT MAX(score_sum)
    FROM (
      SELECT SUM(ideation + implementation + team_dynamics + usp_differentiation) AS score_sum
      FROM evaluations
      GROUP BY project_id
    )
  );
  DBMS_OUTPUT.PUT_LINE('🏆 Winner: ' || v_team_name || ' - "' || v_project_title || '"');
  DBMS_OUTPUT.PUT_LINE('Total Score: ' || v_score);
END;
/

BEGIN
  declare_winner;
END;
/
SELECT * FROM users;
SELECT * FROM judges;
SELECT * FROM organizers;
SELECT * FROM participants;
SELECT * FROM hackathons;
SELECT m.user_id, u.name AS participant_name, m.team_id, t.name AS team_name
FROM member_of m
JOIN users u ON m.user_id = u.id
JOIN teams t ON m.team_id = t.id
ORDER BY m.team_id;
SELECT p.id AS project_id, t.name AS team_name, h.name AS hackathon_name, p.title, p.description
FROM projects p
JOIN teams t ON p.team_id = t.id
JOIN hackathons h ON p.hackathon_id = h.id;
SELECT e.judge_id, u.name AS judge_name, e.project_id, p.title,
       e.ideation, e.implementation, e.team_dynamics, e.usp_differentiation
FROM evaluations e
JOIN users u ON e.judge_id = u.id
JOIN projects p ON e.project_id = p.id
ORDER BY e.project_id, e.judge_id;