
// DB_HOST=nhanes2-dev.c275fkjalvvb.us-east-1.rds.amazonaws.com
// DB_USER=BIOMART_USER
// DB_PASSWORD=biomart_user
// DB_PORT=1521
// DB_DB=ORCL

dataSource {
	dbCreate = 'none'
	dialect = 'org.hibernate.dialect.Oracle10gDialect'
	driverClassName = 'oracle.jdbc.OracleDriver'
	jmxExport = true
	pooled = true
  url = "jdbc:oracle:thin:@localhost:51521/ORCL"
  username = "BIOMART_USER"
  password = "biomart_user"
	properties {
		defaultTransactionIsolation = java.sql.Connection.TRANSACTION_READ_COMMITTED
		initialSize = 5
		jdbcInterceptors = 'ConnectionState'
		jmxEnabled = true
		maxActive = 50
		maxAge = 10 * 60000
		maxIdle = 25
		maxWait = 10000
		minEvictableIdleTimeMillis = 60000
		minIdle = 5
		testOnBorrow = true
		testOnReturn = false
		testWhileIdle = true
		timeBetweenEvictionRunsMillis = 5000
		validationInterval = 15000
		validationQuery = 'SELECT 1 FROM DUAL'
		validationQueryTimeout = 3
	}
}

hibernate {
	// flush.mode = 'manual'
	format_sql = true
	singleSession = true
	use_sql_comments = true
}
