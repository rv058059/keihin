-- DBのデフォルトの照合順序をUTF-8に設定
UPDATE pg_database SET datistemplate = false where datname = 'template1';
DROP DATABASE template1;
CREATE DATABASE template1 LC_COLLATE 'ja_JP.UTF-8' LC_CTYPE 'ja_JP.UTF-8' ENCODING 'UTF8' TEMPLATE template0;
UPDATE pg_database SET datistemplate = true where datname = 'template1';

-- DB作成
CREATE DATABASE timeline
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
