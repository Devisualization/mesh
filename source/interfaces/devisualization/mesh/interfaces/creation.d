﻿/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Devisualization (Richard Andrew Cattermole)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module devisualization.mesh.interfaces.creation;
import devisualization.mesh.interfaces;

// Mesh's

private __gshared {
	Mesh delegate(ubyte[])[string] loaders;
	Mesh delegate(Mesh)[string] convertTos;
}

Mesh meshFromFile(string file) {
	import std.file : read;
	import std.path : extension;
	
	return meshFromData(extension(file)[1 ..$], cast(ubyte[])read(file));
}

Mesh meshFromData(string type, ubyte[] data) {
	if (type in loaders) {
		return loaders[type](data);
	} else {
		throw new NotAMeshException("Unknown file type");
	}
}

Mesh convertTo(Mesh from, string type) {
	if (type in convertTos) {
		return convertTos[type](from);
	} else {
		throw new NotAMeshException("Unknown file type");
	}
}

void registerMeshLoader(string ext, Mesh delegate(ubyte[] data) loader) {
	loaders[ext] = loader;
}

void registerMeshConvertTo(string ext, Mesh delegate(Mesh) converter) {
	convertTos[ext] = converter;
}

alias NotAMeshException = Exception;

// Material's

private __gshared {
	bool delegate(MaterialManager mmgr, string name, void delegate(MaterialManager mmgr, string name, ubyte[] value) fileHandler)[] materialLoaders;
	void delegate(MaterialManager mmgr, string name, ubyte[] value)[] materialFileReaders;

	shared static this() {
		registerMaterialFileReader((MaterialManager mmgr, string name, void delegate(MaterialManager mmgr, string name, ubyte[] value) fileHandler) {
			import std.file : exists, read;
			if (exists(name)) {
				fileHandler(mmgr, name, read(value));
					return true;
			}

			return false;
		});
	}
}

bool loadMaterialFromFile(MaterialManager mgr, string name) {
	 foreach(mfr; materialFileReaders) {
		foreach(ml; materialLoaders) {
			if (ml(mgr, name, mfr))
				return true;
		}
	}

	return false;
}

void registerMaterialParser(void delegate(MaterialManager mmgr, string name, ubyte[] value) fileHandler) {
	materialFileReaders ~= fileHandler;
}

void registerMaterialFileReader(bool delegate(MaterialManager mmgr, string name, void delegate(MaterialManager mmgr, string name, ubyte[] value) fileHandler) handler) {
	materialLoaders ~= handler;
}