/*
 * Copyright (c) 2016, Christopher Atherton <the8lack8ox@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

module bin.crc32tag;

import std.algorithm;
import std.file;
import std.path;
import std.stdio;
import std.string;

import util.crc32;

uint computeCrc32( File file )
{
	Crc32!( 0xEDB88320, true ) crc;

	foreach( ubyte[] buffer; file.byChunk( 4096 ) )
	{
		crc.crunch( buffer );
	}

	return crc.sum;
}

void main( string[] args )
{
	foreach( arg; args[1 .. $] )
	{
		try
		{
			File file = File( arg );
			string base = stripExtension( arg );
			string sum;
			if( base[$-1] == ']' )
				sum = "[" ~ format( "%08X", computeCrc32( file ) ) ~ "]";
			else
				sum = " [" ~ format( "%08X", computeCrc32( file ) ) ~ "]";
			string newName = base ~ sum ~ extension( arg );
			file.close();

			writeln( baseName( newName ) );
			rename( arg, newName );
		}
		catch( Exception err )
		{
			stderr.writeln( "ERROR: ", err.msg );
			stderr.writeln( "ERROR: Tagging \"", arg, "\" failed!" );
		}
	}
}
