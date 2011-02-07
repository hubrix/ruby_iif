# csv_to_iif
# created and copyright 2011: Mark Friedgan (hubrix@hubrix.com)
# 
# input file format: date, transaction, kind, vendor, customer, source, dest, qbmemo
# date: mm/dd/yy
# transaction: -xxxxx.xx
# kind: bill/deposit
# vendor/customer: matches existing vendor/customers in quickbooks or will be added
# source/dest: matches existing accounts in quickbooks or might get added (careful as adding may place in wrong category)
# qbmemo: will end up as memo in quickbooks

require 'ostruct'
require 'csv'

(STDERR.puts "#{__FILE__} input_file.csv {output_file.iif}" or Process.exit!(-1)) unless ARGV[0]

input_filename = ARGV[0]
output_filename = ARGV[1]
output = output_filename ? File.open(output_filename, "w+") : STDOUT
file = File.read(input_filename).gsub("\r","\n")
file_array = CSV.parse(file)
file_array[0].each{|x| x.downcase} #so that all headers a lowercase, uses like to use uppercase and not realize what they are doing
headers = file_array.shift
recordset = file_array.collect {|record| OpenStruct.new(Hash[*headers.zip(record).flatten]) }


#####   CUSTOMERS
#!CUST	NAME	REFNUM	TIMESTAMP	BADDR1	BADDR2	BADDR3	BADDR4	BADDR5	SADDR1	SADDR2	SADDR3	SADDR4	SADDR5	PHONE1	PHONE2	FAXNUM	EMAIL	CONT1	CONT2	CTYPE	TERMS	TAXABLE	LIMIT	RESALENUM	REP	TAXITEM	NOTEPAD	SALUTATION	COMPANYNAME	FIRSTNAME	MIDINIT	LASTNAME	CUSTFLD1	CUSTFLD2	CUSTFLD3	CUSTFLD4	CUSTFLD5	CUSTFLD6	CUSTFLD7	CUSTFLD8	CUSTFLD9	CUSTFLD10	CUSTFLD11	CUSTFLD12	CUSTFLD13	CUSTFLD14	CUSTFLD15	JOBDESC	JOBTYPE	JOBSTATUS	JOBSTART	JOBPROJEND	JOBEND

customers = recordset.collect{|r| r.customer}.uniq.compact
output.puts "!CUST	NAME	REFNUM	TIMESTAMP	BADDR1	BADDR2	BADDR3	BADDR4	BADDR5	SADDR1	SADDR2	SADDR3	SADDR4	SADDR5	PHONE1	PHONE2	FAXNUM	EMAIL	CONT1	CONT2	CTYPE	TERMS	TAXABLE	LIMIT	RESALENUM	REP	TAXITEM	NOTEPAD	SALUTATION	COMPANYNAME	FIRSTNAME	MIDINIT	LASTNAME	CUSTFLD1	CUSTFLD2	CUSTFLD3	CUSTFLD4	CUSTFLD5	CUSTFLD6	CUSTFLD7	CUSTFLD8	CUSTFLD9	CUSTFLD10	CUSTFLD11	CUSTFLD12	CUSTFLD13	CUSTFLD14	CUSTFLD15	JOBDESC	JOBTYPE	JOBSTATUS	JOBSTART	JOBPROJEND	JOBEND"
customers.each {|c| output.puts "CUST	#{c}\n"}

######   VENDORS
#!VEND	NAME	REFNUM	TIMESTAMP	PRINTAS	ADDR1	ADDR2	ADDR3	ADDR4	ADDR5	VTYPE	CONT1	CONT2	PHONE1	PHONE2	FAXNUM	EMAIL	NOTE	TAXID	LIMIT	TERMS	NOTEPAD	SALUTATION	COMPANYNAME	FIRSTNAME	MIDINIT	LASTNAME	CUSTFLD1	CUSTFLD2	CUSTFLD3	CUSTFLD4	CUSTFLD5	CUSTFLD6	CUSTFLD7	CUSTFLD8	CUSTFLD9	CUSTFLD10	CUSTFLD11	CUSTFLD12	CUSTFLD13	CUSTFLD14	CUSTFLD15	1099
vendors = recordset.collect{|r| r.vendor}.uniq.compact
output.puts "!VEND	NAME	REFNUM	TIMESTAMP	PRINTAS	ADDR1	ADDR2	ADDR3	ADDR4	ADDR5	VTYPE	CONT1	CONT2	PHONE1	PHONE2	FAXNUM	EMAIL	NOTE	TAXID	LIMIT	TERMS	NOTEPAD	SALUTATION	COMPANYNAME	FIRSTNAME	MIDINIT	LASTNAME	CUSTFLD1	CUSTFLD2	CUSTFLD3	CUSTFLD4	CUSTFLD5	CUSTFLD6	CUSTFLD7	CUSTFLD8	CUSTFLD9	CUSTFLD10	CUSTFLD11	CUSTFLD12	CUSTFLD13	CUSTFLD14	CUSTFLD15	1099"

vendors.each {|v| output.puts "VEND	#{v}\n"}

######   TRANSACTIONS

#!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	NAME	AMOUNT	DOCNUM	MEMO	CLEAR	TOPRINT	
#!SPL	SPLID	TRNSTYPE	DATE	ACCNT	NAME	AMOUNT	DOCNUM	MEMO	CLEAR	QNTY
#!ENDTRNS																			
#TRNS		BILLPMT	7/16/98	Checking	Vendor	-35		Test Memo	N	Y										
#SPL		BILLPMT	7/16/98	Accounts Payable	Vendor	35			N											
#ENDTRNS

#TRNS	 	DEPOSIT	7/1/98	Checking			10000			N
#SPL		DEPOSIT	7/1/98	Income	Customer		-10000			N


output.puts "!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	NAME	AMOUNT	DOCNUM	MEMO	CLEAR	TOPRINT"	
output.puts "!SPL	SPLID	TRNSTYPE	DATE	ACCNT	NAME	AMOUNT	DOCNUM	MEMO	CLEAR	QNTY"
output.puts "!ENDTRNS"
 recordset.each do |record|
  kind = record.kind =="bill" ? "BILLPMT" : "DEPOSIT"
  date = record.date #assuming excel saved as 2 digit date, who the hell uses 2 digit dates, stupid INTUIT????
  name1 = record.vendor
  name2 = record.kind == "bill" ? record.vendor : record.customer
  #trn
  output.puts "TRNS		#{kind}	#{date}	#{record.source}	#{name1}	#{record.transaction.to_f}		#{record.qbmemo}	N" 
  #spl 
  output.puts "SPL		#{kind}	#{date}	#{record.dest}	#{name2}	#{-record.transaction.to_f}		#{record.qbmemo}	N"
  output.puts "ENDTRNS"
 end
