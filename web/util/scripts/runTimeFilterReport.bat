REM parameters: <db.cfg-path> <report.xml-filename> <mail-server> <from> <to>
cd c:\projects\openclinicnew\web\util
java -Xms64m -Xmx256m -classpath ../WEB-INF/classes;../WEB-INF/lib/mail.jar;../WEB-INF/lib/commons-httpclient-3.1.jar;../WEB-INF/lib/log4j.jar;../WEB-INF/lib/primrose.jar;../WEB-INF/lib/jtds-0.9.jar;../WEB-INF/lib/sqljdbc4.jar;../WEB-INF/lib/mysql-connector-java-5.1.10-bin.jar;../WEB-INF/lib/CacheDB.jar;../WEB-INF/lib/dom4j-full.jar be.openclinic.reporting.TimeFilterReportGenerator %1 %2 %3 %4 %5
