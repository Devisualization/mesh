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
module devisualization.mesh.wavefront_obj.defs;
import devisualization.mesh.interfaces.mesh;

class WavefrontObjMesh : Mesh {
	package {
		Vertex[] vertices_;
		Face[] faceVertices;
	}

	this(ubyte[] data) {
		import devisualization.mesh.wavefront_obj.reader;
		parseWaveFrontObjMesh(this, data);
	}

	this(Mesh mesh) {
		vertices_.length = mesh.vertices.length;

		foreach(size_t vi, Vertex v; mesh) {
			vertices_[vi] = Vertex(v.x, v.y, v.z, v.w);
		}

		faceVertices.length = mesh.faces.length;
		foreach(size_t fi, Face f; mesh) {
			with(faceVertices[fi]) {

				vertices.length = f.vertices.length;
				foreach(size_t i, size_t vi; f.vertices) {
					vertices[i] = vi;
				}

				textureCoords.length = f.textureCoords.length;
				foreach(size_t i, vec3 vi; f.textureCoords) {
					textureCoords[i] = vec3(vi.x, vi.y, vi.z);
				}

				normals.length = f.normals.length;
				foreach(size_t i, vec3 vi; f.normals) {
					normals[i] = vec3(vi.x, vi.y, vi.z);
				}
			}
		}
	}

	@property {
		Vertex[] vertices() {
			return vertices_;
		}

		Face[] faces() {
			return faceVertices;
		}
	}

	Vertex vertex(size_t i)
	in {
		assert(i < vertices_.length);
	} body {
		return vertices_[i];
	}
	
	int opApply(int delegate(Vertex) del) {
		foreach(size_t vi, v; vertices_) {
			int result = del(v);
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(size_t, Vertex) del) {
		foreach(size_t vi, v; vertices_) {
			int result = del(vi, v);
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(Face) del) {
		foreach(size_t vi, v; faceVertices) {
			int result = del(v);
			if (result)
				return result;
		}
		return 0;
	}

	int opApply(int delegate(size_t, Face) del) {
		foreach(size_t vi, v; faceVertices) {
			int result = del(vi, v);
			if (result)
				return result;
		}
		return 0;
	}

	ubyte[] exportFrom() {
		import devisualization.mesh.wavefront_obj.writer;
		return exportWaveFrontObjMesh(this);
	}

	void exportTo(string file) {
		import std.file : write;
		write(file, exportFrom());
	}
}