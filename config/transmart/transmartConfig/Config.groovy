import org.transmart.searchapp.AuthUser
import org.transmart.searchapp.Requestmap
import org.transmart.searchapp.Role

grails {
	plugin {
		springsecurity {

			auth0 {
				active = false
				clientId = 'ywAq4Xu4Kl3uYNdm3m05Cc5ow0OibvXt'
				clientSecret = 'nQWNixJHJ_jRWd6ZuFY9XJNdt9-gDvqBkpN9b80qHn7ySpCUfTdwIm0F85UZgbB4'
				domain = 'avillachlab.auth0.com'
				useRecaptcha = false
				registrationEnabled = false
				webtaskBaseUrl = 'https://avillachlab.us.webtask.io'
			}

			apf.storeLastUsername = true
			authority.className = Role.name
			rejectIfNoRule = false // revert to old behavior
			fii.rejectPublicInvocations = false // revert to old behavior
			logout.afterLogoutUrl = '/'
			requestMap.className = Requestmap.name
			//securityConfigType = 'Requestmap'

			successHandler.defaultTargetUrl = '/userLanding'

			userLookup {
				authorityJoinClassName = AuthUser.name
				passwordPropertyName = 'passwd'
				userDomainClassName = AuthUser.name
			}

      controllerAnnotations.staticRules = [
                '/**':                          'IS_AUTHENTICATED_REMEMBERED',
                '/accessLog/**':                'ROLE_ADMIN',
                '/analysis/getGenePatternFile': 'permitAll',
                '/analysis/getTestFile':        'permitAll',
                '/authUser/**':                 'ROLE_ADMIN',
                '/authUserSecureAccess/**':     'ROLE_ADMIN',
                '/css/**':                      'permitAll',
                '/images/**':                   'permitAll',
                '/js/**':                       'permitAll',
                '/login/**':                    'permitAll',
                '/requestmap/**':               'ROLE_ADMIN',
                '/role/**':                     'ROLE_ADMIN',
                '/search/loadAJAX**':           'permitAll',
                '/secureObject/**':             'ROLE_ADMIN',
                '/secureObjectAccess/**':       'ROLE_ADMIN',
                '/secureObjectPath/**':         'ROLE_ADMIN',
                '/userGroup/**':                'ROLE_ADMIN',
                '/auth0/**':                    'permitAll',
                '/registration/**':             'permitAll',
                '/console/**': 'permitAll'
      ]
		}
	}
}

com.recomdata.appTitle = 'i2b2/tranSMART Gabe NHANES'
com.recomdata.largeLogo = 'transmartlogoHMS.jpg'

edu.harvard.transmart.email.notify = 'gabor_korodi@hms.harvard.edu'
edu.harvard.transmart.email.logo = '/images/info_security_logo_rgb.png'

org.transmart.security.oauthEnabled = true
org.transmart.security.oauth.service_url = 'http://ec2-54-89-191-200.compute-1.amazonaws.com'
org.transmart.security.oauth.login_endpoint = '/admin/login'
org.transmart.security.oauth.service_token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2F2aWxsYWNobGFiLmF1dGgwLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDExMDU3NTU5OTQ3MDYzNjg3ODkyMCIsImF1ZCI6Inl3QXE0WHU0S2wzdVlOZG0zbTA1Q2M1b3cwT2lidlh0IiwiaWF0IjoxNTQ2OTY2NjQzLCJleHAiOjE1NDg5NzU2MDB9.0ee6v-ftcO2May0mpy8fLTD82w6Abey5MxEOCRrAlkU'
org.transmart.security.oauth.application_id = '8026b745-5318-4778-97ea-8b08388bda24'

com.recomdata.adminEmail = 'gabor_korodi@hms.harvard.edu'
com.recomdata.contactUs = 'gabor_korodi@hms.harvard.edu'

com.rwg.solr.scheme = 'http'
com.rwg.solr.host   = '192.168.99.100:8983'
com.rwg.solr.browse.path   = '/solr/rwg/select/'


//Configurations for solr.
com.recomdata.solr.baseURL = 'http://192.168.99.100:8983'
//This is needed because solr won't allow a return of all records.
com.recomdata.solr.maxRows = '1000000'
//This is the number of results we display before drawing the "More [+]" text.
com.recomdata.solr.maxLinksDisplayed = 5
//This is the list of columns we don't draw in the application.
com.recomdata.solr.fieldExclusionList = "text|id|"
//This is the maximum number of news stories we display.
com.recomdata.solr.maxNewsStories = 10
//This is the number of items we display in the search suggestion box.
com.recomdata.solr.numberOfSuggestions = 20

ui.tabs.sampleExplorer.show = true

sampleExplorer.testConfigVar = true

sampleExplorer.fieldMapping = [
columns:[ [ header:'Barcode',dataIndex:'BARCODE', mainTerm: false, showInGrid: false, width:10], [header:'Sample Alias', dataIndex:'SAMPLE_ALIAS', mainTerm: true, showInGrid: true, width:15], [header:'Status',dataIndex:'STATUS', mainTerm: true, showInGrid: true, width:8], [header:'Material Name',dataIndex:'MATERIAL_NAME', mainTerm: true, showInGrid: true, width:15], [header:'Material Code',dataIndex:'MATERIAL_CODE', mainTerm: false, showInGrid: true, width:15], [header:'Container',dataIndex:'CONTAINER', mainTerm: true, showInGrid: true, width:25], [header:'Amount',dataIndex:'AMOUNT', mainTerm: true, showInGrid: true, width:8], [header:'Units',dataIndex:'UNITS', mainTerm: true, showInGrid: true, width:5], [header:'Collection Year',dataIndex:'COLLECTION_YEAR', mainTerm: true, showInGrid: true, width:15], [header:'Project',dataIndex:'PROJECT', mainTerm: true, showInGrid: true, width:15], [header:'Organization',dataIndex:'ORGANIZATION', mainTerm: true, showInGrid: true, width:15], [header:'Accession Number',dataIndex:'ACCESSION_NUMBER', mainTerm: false, showInGrid: false, width:5], [header:'Aliquot Number',dataIndex:'ALIQUOT_NUMBER', mainTerm: false, showInGrid: false], [header:'Container Code',dataIndex:'CONTAINER_CODE', mainTerm: false, showInGrid: true, width:15], [header:'Description',dataIndex:'DESCRIPTION', mainTerm: false, showInGrid: false], [header:'Material Type',dataIndex:'MATERIAL_TYPE', mainTerm: true, showInGrid: false, width:15], [header:'Parent Sample Alias',dataIndex:'PARENT_SAMPLE_ALIAS', mainTerm: true, showInGrid: true, width:10], [header:'Thaw count',dataIndex:'THAW_COUNT', mainTerm: false, showInGrid: false], [header:'Temperature Current', dataIndex:'TEMPERATURE_CURRENT', mainTerm: false, showInGrid: false, width:10], [header:'Temperature Instructions',dataIndex:'TEMPERATURE_INSTRUCTIONS', mainTerm: false, showInGrid: false, width:10], [header:'Temperature Upon Receipt',dataIndex:'TEMPERATURE_UPON_RECEIPT', mainTerm: false, showInGrid: false, width:10], [header:'Age At Collection Subject',dataIndex:'AGE_AT_COLLECTION_SUBJECT', mainTerm: false, showInGrid: false, width:10], [header:'Case Or Control Sample',dataIndex:'CASE_OR_CONTROL_SAMPLE', mainTerm: false, showInGrid: false], [header:'Collection Amount',dataIndex:'COLLECTION_AMOUNT', mainTerm: false, showInGrid: false, width:10], [header:'Collection Number',dataIndex:'COL_NUMBER', mainTerm: false, showInGrid: false, width:10], [header:'Collection Time',dataIndex:'COL_TIME', mainTerm: false, showInGrid: false, width:15], [header:'Primary Specimen Collection Time',dataIndex:'PRIMARY_SPECIMEN_COL_TIME', mainTerm: false, showInGrid: false], [header:'Primary Container',dataIndex:'PRIMARY_CONTAINER', mainTerm: false, showInGrid: false], [header:'Primary Container Code',dataIndex:'PRIMARY_CONTAINER_CODE', mainTerm: false, showInGrid: false, width:10], [header:'Primary Specimen',dataIndex:'PRIMARY_SPECIMEN', mainTerm: false, showInGrid: false], [header:'Primary Specimen Code',dataIndex:'PRIMARY_SPECIMEN_CODE', mainTerm: false, showInGrid: false, width:10], [header:'Autopsy Consent',dataIndex:'AUTOPSY_CONSENT', mainTerm: false, showInGrid: false, width:10], [header:'Passage Number',dataIndex:'PASSAGE_NUMBER', mainTerm: false, showInGrid: false, width:5], [header:'Blood Borne Pathogens',dataIndex:'BLOOD_BORNE_PATHOGENS', mainTerm: false, showInGrid: false], [header:'Freezing Medium',dataIndex:'FREEZING_MEDIUM', mainTerm: false, showInGrid: false, width:30], [header:'Gross Impression',dataIndex:'GROSS_IMPRESSION', mainTerm: v, showInGrid: false, width:5], [header:'Human Tissue Fixation Time',dataIndex:'HUMAN_TISSUE_FIXATION_TIME', mainTerm: false, showInGrid: false], [header:'Human Tissue Collection Procedure',dataIndex:'HUMAN_TISSUE_COL_PROCEDURE', mainTerm: false, showInGrid: false], [header:'Human Tissue Freezing Method',dataIndex:'HUMAN_TISSUE_FREEZING_METHOD', mainTerm: false, showInGrid: false], [header:'Human Tissue Fixation Type',dataIndex:'HUMAN_TISSUE_FIXATION_TYPE', mainTerm: false, showInGrid: false, width:30], [header:'Human Tissue Freezing Medium',dataIndex:'HUMAN_TISSUE_FREEZING_MEDIUM', mainTerm: false, showInGrid: false, width:30], [header:'NucleicAcid 28s18s',dataIndex:'NUCLEICACID_28S_18S', mainTerm: false, showInGrid: false, width:10], [header:'NucleicAcid RIN',dataIndex:'RIN', mainTerm: false, showInGrid: false, width:10], [header:'NucleicAcid A260 A230',dataIndex:'A260_A230', mainTerm: false, showInGrid: false, width:10], [header:'Concentration BioAnalyzer',dataIndex:'CONCENTRATION_BIOANALYZER', mainTerm: false, showInGrid: false, width:10], [header:'Concentration DS DNA',dataIndex:'CONCENTRATION_DS_DNA', mainTerm: false, showInGrid: false, width:10], [header:'Concentration Unknown Assay',dataIndex:'CONCENTRATION_UNKNOWN_ASSAY', mainTerm: false, showInGrid: false, width:10], [header:'NucleicAcid A260 A280',dataIndex:'A260_A280', mainTerm: false, showInGrid: false, width:10], [header:'Concentration A260',dataIndex:'CONCENTRATION_A260', mainTerm: false, showInGrid: false, width:10], [header:'Micrograms',dataIndex:'MICROGRAMS', mainTerm: false, showInGrid: true, width:5] ] ]

edu.harvard.transmart.sampleBreakdownMap = [
	"PATIENT_NUM":"Patients in Cohort with samples",
	"id":"Aliquots in Cohort"
]

String jobsDirectory = '/tmp' // '/var/tmp/jobs/'
RModules.tempFolderDirectory = jobsDirectory
RModules.external = true
com.recomdata.plugins.tempFolderDirectory = RModules.tempFolderDirectory

//com.recomdata.guestAutoLogin=true
//com.recomdata.guestUserName='guest'

log4j = {
	appenders {
		rollingFile name: 'file', maxFileSize: 1024 * 1024, file: 'logs/app.log'
		rollingFile name: 'sql',  maxFileSize: 1024 * 1024, file: 'logs/sql.log'
	}

	error 'org.codehaus.groovy.grails',
	      'org.springframework',
	      'org.hibernate',
	      'net.sf.ehcache.hibernate'
	debug sql: 'org.hibernate.SQL'
	// trace sql: 'org.hibernate.type.descriptor.sql.BasicBinder'

	root {
		debug 'file'
	}
}

org.transmart.configFine = true

grails {
    mail {
        host = 'smtp.gmail.com'
        port = 465
        username = 'hms.dbmi.data.infrastructure@gmail.com'
        password = 'NsSbuFr8zVLtVgCH'
        props = ['mail.smtp.auth': 'true',
                 'mail.smtp.socketFactory.port': '465',
                 'mail.smtp.socketFactory.class': 'javax.net.ssl.SSLSocketFactory',
                 'mail.smtp.socketFactory.fallback': 'false']
    }
}
