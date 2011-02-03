  use Finance::QIF;
  
  my $qif = Finance::QIF->new( file => "/Users/mark/Desktop/fs.qif" );
  print("payee,transaction,status,date,category,memo\n"); 
  while ( my $record = $qif->next ) {
      if ($record->{header} eq "Type:Bank"){
        chop($record->{payee});
	chop($record->{transaction});
	chop($record->{status});
	chop($record->{date});$record->{date} =~ s/'10/\/2010/g;$record->{date} =~ s/' /\/200/g;
	chop($record->{category});
	chop($record->{memo});
	print(
	  $record->{payee}, ";", 
	  $record->{transaction}, ";", 
	  $record->{status}, ";", 
	  $record->{date}, ";", 
	  $record->{category}, ";", 
	  $record->{memo}, "\n");
      }
  }

