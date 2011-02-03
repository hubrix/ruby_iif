  use Finance::QIF;
  
  my $qif = Finance::QIF->new( file => "/Users/mark/Desktop/fs.qif" );
  
  while ( my $record = $qif->next ) {
      print( "", $record->{header}, "\n" );
      foreach my $key ( keys %{$record} ) {
          next
            if ( $key eq "header"
              || $key eq "splits"
              || $key eq "budget"
              || $key eq "prices" );
          print( "     ", $key, ": ", $record->{$key}, "\n" );
      }
      if ( exists( $record->{splits} ) ) {
          foreach my $split ( @{ $record->{splits} } ) {
              foreach my $key ( keys %{$split} ) {
                  print( "     Split: ", $key, ": ", $split->{$key}, "\n" );
              }
          }
      }
      if ( exists( $record->{budget} ) ) {
          print("     Budget: ");
          foreach my $amount ( @{ $record->{budget} } ) {
              print( " ", $amount );
          }
          print("\n");
      }
      if ( exists( $record->{prices} ) ) {
        #  print("     Date     Close   Max     Min     Volume\n");
        #  $format = "     %8s %7.2f %7.2f %7.2f %-8d\n";
        #  foreach my $price ( @{ $record->{prices} } ) {
        #      printf( $format,
        #          $price->{"date"}, $price->{"close"}, $price->{"max"},
        #          $price->{"min"},  $price->{"volume"} );
        #  }
      }
  }

