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
module devisualization.mesh.wavefront_obj.reader;
import devisualization.mesh.wavefront_obj.defs;
import devisualization.mesh.interfaces.mesh;

/**
 * Parses wavefront obj meshes.
 * 
 * Supported:
 * 		Vertex (v)
 * 		Texture coordinate (vt)
 * 		Vertex normal (vn)
 * 		Face (f)
 * 		Comments (# ... \n)
 * 
 * Standards:
 * 		http://www.martinreddy.net/gfx/3d/OBJ.spec
 */
void parseWaveFrontObjMesh(WavefrontObjMesh _, ubyte[] data) {
	with(_) {
		bool inComment;
		string buffer;
		vec3[] textureCoords;
		vec3[] normals;

		void endLine() {
			_.parseLine(buffer, textureCoords, normals);

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

void parseLine(WavefrontObjMesh _, string buffer, ref vec3[] textureCoords, ref vec3[] normals) {
	import devisualization.util.core.text : split;
	import gl3n.linalg : vec3, vec4;
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
			case "v":
				string[] indicies = buffer.split(" ");

				float x = 0f;
				float y = 0f;
				float z = 0f;

				if (indicies.length >= 3) {
					x = to!float(indicies[0]);
					y = to!float(indicies[1]);
					z = to!float(indicies[2]);
				}

				float w = 1f;

				if (indicies.length >= 4) {
					w = to!float(indicies[3]);
				}

				vertices_ ~= Vertex(x, y, z, w);
				break;

			case "vt":
				string[] indicies = buffer.split(" ");
				
				float u = 0f;
				float v = 0f;
				
				if (indicies.length >= 2) {
					u = to!float(indicies[0]);
					v = to!float(indicies[1]);
				}

				float w = 0f;

				if (indicies.length >= 3) {
					w = to!float(indicies[2]);
				}
				
				textureCoords ~= vec3(u, v, w);
				break;

			case "vn":
				string[] indicies = buffer.split(" ");

				float x = 0f;
				float y = 0f;
				
				if (indicies.length >= 2) {
					x = to!float(indicies[0]);
					y = to!float(indicies[1]);
				}
				
				float z = 0f;
				
				if (indicies.length >= 3) {
					z = to!float(indicies[2]);
				}
				
				normals ~= vec3(x, y, z);
				break;

			case "f":
				Face face = Face(_);

				string[] indicies = buffer.split(" ");
				foreach(indicie; indicies) {
					string[] parts = indicie.split("/");

					if (parts.length > 0 && parts[0] != "") {
						size_t v = to!size_t(parts[0]);
						if (v < vertices_.length + 1) {
							face.vertices ~= v - 1;

							if (parts.length > 1 && parts[1] != "") {
								size_t tc = to!size_t(parts[1]);
								if (tc < textureCoords.length + 1) {
									face.textureCoords ~= textureCoords[tc - 1];
								}
							}

							if (parts.length > 2 && parts[2] != "") {
								size_t tn = to!size_t(parts[2]);
								if (tn < normals.length + 1) {
									face.normals ~= normals[tn - 1];
								}
							}
						}
					}
				}

				faceVertices ~= face;
				break;

			case "mtllib":
				import devisualization.mesh.interfaces.creation : loadMaterialFromFile;
				_.mmgr.loadMaterialFromFile(buffer);
				break;

			case "usemtl":
				_.material_ = _.mmgr.retrieve(buffer);
				break;

			default:
				break;
		}
	}
}