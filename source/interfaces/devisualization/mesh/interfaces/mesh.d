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
module devisualization.mesh.interfaces.mesh;
import gl3n.linalg : vec3, vec4;

alias Vertex = vec4;

struct Face {
	size_t[] vertices;
	vec3[] textureCoords;
	vec3[] normals;
	
	private {
		Mesh from;
	}
	
	this(Mesh from) {
		this.from = from;
	}
	
	int opApply(int delegate(Vertex) del) {
		foreach(vi, v; vertices) {
			int result = del(from.vertex(v));
			if (result)
				return result;
		}
		return 0;
	}
	
	int opApply(int delegate(size_t, Vertex) del) {
		foreach(vi, v; vertices) {
			int result = del(v, from.vertex(v));
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(Vertex, vec3) del) {
		foreach(vi, v; vertices) {
			int result = del(from.vertex(v), textureCoords.length > vi ? textureCoords[vi] : vec3.init);
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(size_t, Vertex, vec3) del) {
		foreach(vi, v; vertices) {
			int result = del(v, from.vertex(v), textureCoords.length > vi ? textureCoords[vi] : vec3.init);
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(Vertex, vec3, vec3) del) {
		foreach(vi, v; vertices) {
			int result = del(from.vertex(v), textureCoords.length > vi ? textureCoords[vi] : vec3.init, normals.length > vi ? normals[vi] : vec3.init);
			if (result)
				return result;
		}
		return 0;
	}
	
	int opApply(int delegate(size_t, Vertex, vec3, vec3) del) {
		foreach(vi, v; vertices) {
			int result = del(v, from.vertex(v), textureCoords.length > vi ? textureCoords[vi] : vec3.init, normals.length > vi ? normals[vi] : vec3.init);
			if (result)
				return result;
		}
		return 0;
	}
}

interface Mesh {
	// this(ubyte[]);
	// this(Mesh);

	@property {
		Vertex[] vertices();
		Face[] faces();
	}
	
	Vertex vertex(size_t);

	int opApply(int delegate(Vertex));
	int opApply(int delegate(size_t, Vertex));
	
	int opApply(int delegate(Face));
	int opApply(int delegate(size_t, Face));

	ubyte[] exportFrom();
	void exportTo(string file);
}