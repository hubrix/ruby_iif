my $qif = Finance::QIF->new( file => "/Users/mark/Desktop/fs.qif");while (my $record = $qif->next()) {print Dumper($record->{header});print"\n";};
