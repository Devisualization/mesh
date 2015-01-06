Devisualization mesh loading/exporting
====
Loads and exports 3d meshes

Supports
-------
* Wavefront obj

Example
------
```D
import devisualization.mesh;
import devisualization.mesh.wavefront_obj;

void main() {
	Mesh mesh = meshFromFile("myMesh.obj");
	mesh.exportTo("myNewMesh.obj");
	
	foreach(Face f; mesh.faces) {
		foreach(Vertex v, vt, vn; f) {
			// add vertex, vertex texture coord and vertex normal to buffers
		}
	}
}
```

TODO
----
* Animation file formats (maybe a container of other formats?)
* Editable
* More formats (STL, 3ds)