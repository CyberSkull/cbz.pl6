#! /usr/bin/env perl6

sub MAIN(Bool :k($keep), Bool :d($debug), *@folders)
{
  my ($folder, $target, $flags, @promises, @args);

  # configure flags
  # -m delete originals
  # -r recursive, required
  # -T test file
  # -y follow symbolic links
  # -9 maximum compression
  $flags = "-" ~ ($keep ?? "" !! "m") ~ "rTy9";
  say "zip flags: $flags" if $debug;

  for @folders
  {
    $folder = IO::Path.new($_);
    next unless ($folder.d and $folder.r); #$folder is a directory and readable
    @args = [$flags, $folder.basename ~ "\.cbz", $folder.basename, "-x", "*.DS_Store", "*[Tt]humbs.db"];
    say "zip " ~ @args if $debug;
    @promises.push(Proc::Async.new("zip", @args).start);
  }
  await @promises;
  say "Completed in " ~ (now - INIT now) ~ " seconds." if $debug;
}

=begin pod

=head1 NAME

cbz – Perl 6 Comic Book Zip utility

=head1 SYNOPSIS

    cbz.pl6 [-k] [-d] [<folders> ...]

=head1 DESCRIPTION

cbz automates creating Comic Book Zip (.cbz) files. Just pass a list of directories
you want zipped and it will create them and remove the orignals. This script
will also launch multiple instances of zip to finish faster.

=head1 ARGUMENTS

=head2 -k

Keeps the originals instead of having zip remove the orignals after a
successful test of the archive.

=head2 -d

Prints various debug information. For developers, really.

=head2 FOLDERs

The folders that cbz will turn into .cbz files.

=head1 IGNORED FILES

.DS_Store & Thumbs.db files will be ignored by zip, so they don't clutter up
your comics.
=end pod
