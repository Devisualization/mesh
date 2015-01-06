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
module devisualization.mesh.wavefront_obj.writer;
import devisualization.mesh.wavefront_obj.defs;
import devisualization.mesh.interfaces.mesh;
import gl3n.linalg : vec3, vec4;

/**
 * Exports wavefront obj meshes.
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
ubyte[] exportWaveFrontObjMesh(WavefrontObjMesh _) {
	import std.conv : to;
	import std.algorithm : canFind, countUntil;
	ubyte[] ret;

	with(_) {
		foreach(v; vertices_) {
			ret ~= "v ";
			ret ~= to!string(v.x);
			ret ~= " ";
			ret ~= to!string(v.y);
			ret ~= " ";
			ret ~= to!string(v.z);
			ret ~= " ";
			ret ~= to!string(v.w);
			ret ~= "\r\n";
		}

		vec3[] textureCoords;
		vec3[] normals;

		foreach(face; faceVertices) {
			foreach(tc; face.textureCoords) {
				if (!textureCoords.canFind(tc))
					textureCoords ~= tc;
			}
			foreach(tn; face.normals) {
				if (!normals.canFind(tn))
					normals ~= tn;
			}
		}

		foreach(tc; textureCoords) {
			ret ~= "vt ";
			ret ~= to!string(tc.x);
			ret ~= " ";
			ret ~= to!string(tc.y);
			ret ~= " ";
			ret ~= to!string(tc.z);
			ret ~= "\r\n";
		}

		foreach(tn; normals) {
			ret ~= "vn ";
			ret ~= to!string(tn.x);
			ret ~= " ";
			ret ~= to!string(tn.y);
			ret ~= " ";
			ret ~= to!string(tn.z);
			ret ~= "\r\n";
		}

		foreach(face; faceVertices) {
			ret ~= "f ";

			if (textureCoords.length > 0 && normals.length > 0) {
				foreach(size_t vi, Vertex v, vt, vn; face) {
					ret ~= to!string(vi + 1);
					ret ~= "/";
					ret ~= to!string(textureCoords.countUntil(vt) + 1);
					ret ~= "/";
					ret ~= to!string(normals.countUntil(vn) + 1);
					ret ~= " ";
				}
				
				ret.length--;
			} else if (textureCoords.length > 0) {
				foreach(size_t vi, Vertex v, vt; face) {
					ret ~= to!string(vi + 1);
					ret ~= "/";
					ret ~= to!string(textureCoords.countUntil(vt) + 1);
					ret ~= " ";
				}

				ret.length--;
			} else if (normals.length > 0) {
				foreach(size_t vi, Vertex v, vt, vn; face) {
					ret ~= to!string(vi + 1);
					ret ~= "//";
					ret ~= to!string(normals.countUntil(vn) + 1);
					ret ~= " ";
				}
				
				ret.length--;
			} else {
				foreach(size_t vi, Vertex v, vt, vn; face) {
					ret ~= to!string(vi + 1);
					ret ~= " ";
				}
				
				ret.length--;
			}

			ret ~= "\r\n";
		}
	}

	return ret;
}