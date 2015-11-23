# Introduction #

This page contains a range on notes on how the persistence features mentioned in [issue 5](https://code.google.com/p/mplayer-library/issues/detail?id=5) could be implemented


# Details #

## Program Internals ##

An object, or similar, should be created to hold a generic video, whether episode, movie, multimovie etc.

Proper design should make this work with the DVD options as well, as sorting them is currently a bit dodgy ([issue 10](https://code.google.com/p/mplayer-library/issues/detail?id=10) and [issue 13](https://code.google.com/p/mplayer-library/issues/detail?id=13)).

The current index file contains some relevant data.

## External storage ##

A database might be nice (SQLite), but text files are so easy to work with they might be preferable - something like the current index (tab-delimited) is quite easy to edit.

Maybe XML could work, although it might be a [pain in Perl](http://search.cpan.org/~shlomif/XML-LibXML-2.0014/LibXML.pod).

It could be possible to sync between a database and a text version, backing up from one to another. **This should be done in a separate thread** if it happens during boot/startup/normal program flow

## Bedtime/series link ##

[Issue 8](https://code.google.com/p/mplayer-library/issues/detail?id=8) requires some form of storage of current episode, which should really be tied into however [issue 13](https://code.google.com/p/mplayer-library/issues/detail?id=13) is resolved.

However, a quick-and-dirty solution could be created just by storing the previous episode number in a text file in the config folder.