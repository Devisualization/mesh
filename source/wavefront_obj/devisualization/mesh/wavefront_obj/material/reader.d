/*
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
module devisualization.mesh.wavefront_obj.material.reader;
import devisualization.mesh.interfaces.material;
import devisualization.mesh.wavefront_obj.material.defs;

/**
 * Supported:
 * 		newmtl
 * 		Ka
 * 		Kd
 * 		Ks
 * 		d
 * 		Tr
 * 
 * TODO:
 * 		illum
 * 		map_Ka
 * 		map_Kd
 * 		map_Ks
 * 		map_d
 * 		map_bump
 * 		bump
 * 		disp
 * 		decal
 * 		refl
 */
void parseWaveFrontMaterial(MaterialManager _, ubyte[] data) {
	with(_) {
		bool inComment;
		string buffer;
		WaveFrontMaterial lastMaterial;

		void endLine() {
			_.parseWaveFrontMaterialLine(buffer, lastMaterial);
			
			buffer = null;
		}
		
		foreach(d; data) {
			if (inComment && (d == '\r' || d == '\n')) {
				inComment = false;
				buffer = null;
			} else if (d == '\r' || d == '\n') {
				endLine;
			} else if (d == '#') {
				if (!inComment)
					endLine;
				inComment = true;
			} else if (!inComment) {
				buffer ~= d;
			}
		}
	}
}

void parseWaveFrontMaterialLine(MaterialManager _, string buffer, WaveFrontMaterial lastMaterial) {
	import devisualization.image.color;
	import devisualization.util.core.text : split;
	import std.string : toLower;
	import std.conv : to;
	
	with(_) {
		string op;
		foreach(size_t i, c; buffer) {
			if (c == ' ') {
				buffer = buffer[i .. $];
				break;
			}
			op ~= c;
		}
		if (buffer.length == 0)
			return;
		
		buffer = buffer[1 .. $];
		
		switch(op.toLower) {
			case "newmtl":
				lastMaterial = new WaveFrontMaterial;
				_.store(buffer, lastMaterial);
				break;
			case "ka":
				string[] parts = buffer.split(" ");
				if (parts.length == 3) {
					try {
						lastMaterial.ambient_ = Color_RGBA(to!float(parts[0]), to!float(parts[1]), to!float(parts[2]), 1f);
					} catch (Exception e) {}
				}
				break;
			case "kd":
				string[] parts = buffer.split(" ");
				if (parts.length == 3) {
					try {
						lastMaterial.diffuse_ = Color_RGBA(to!float(parts[0]), to!float(parts[1]), to!float(parts[2]), 1f);
					} catch (Exception e) {}
				}
				break;
			case "ks":
				string[] parts = buffer.split(" ");
				if (parts.length == 3) {
					try {
						lastMaterial.specular_ = Color_RGBA(to!float(parts[0]), to!float(parts[1]), to!float(parts[2]), 1f);
					} catch (Exception e) {}
				}
				break;
			case "ns":
				try {
					lastMaterial.specularWeighting_ = to!ushort(buffer);
				} catch (Exception e) {}
				break;
			case "d":
			case "tr":
				try {
					lastMaterial.transparency_ = to!float(buffer);
				} catch (Exception e) {}
				break;

			default:
				break;
		}
	}
}