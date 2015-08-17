part of planner;

// Layer Preview class
class Preview
{
	/*
	 * Defaults
	 */
	static const UPDATE_EVENT			= 'previewUpdate',
				 UPDATE_WALL_EVENT		= 'previewUpdateWall',
				 DELETE_WALL_EVENT		= 'previewDeleteWall',
				 PAN_EVENT				= 'panPreview',
				 FOV					= 75.0;

	/*
	 * Data
	 */
	Map<String, StreamSubscription> _listeners	= new Map<String, StreamSubscription>();
	//List<Timer>						_activeTimers = new List<Timer>();
	WebGLRenderer					_renderer;
	PerspectiveCamera				_camera;
	//Set/*<Light>*/						_light;
	Light							_light;
	Light							_light2;
	Scene							_scene;
	Object3D						_mesh;
	Mesh							_plane;
	final Rectangle					_base;
	
	/*
	 * Constructor
	 */
	Preview (Rectangle this._base)
	{
		// Data
		this._renderer		= new WebGLRenderer(clearAlpha: 1.0, clearColorHex: 0xFFFFFF, antialias: true);
		//this._renderer.shadowMapEnabled = true;
		
		this._camera		= new PerspectiveCamera(FOV, this.width / this.height);
		
		this._mesh			= new Object3D();
        this._mesh.castShadow = true;
        this._mesh.receiveShadow = true;
		
		//this._light.add(new HemisphereLight(0x0000FF, 0x00FF00, intensity: 0.6));
		this._light = new PointLight(0xDDDDDD);
		this._light.castShadow = true;
		//this._light.shadowCameraNear = 1.0;
		//this._light.shadowCameraFar = 5000.0;
		//this._light.shadowCameraFov = 50.0;
		//this._light.shadowCameraVisible = true;
		//this._light.position.x = this.width.toDouble();
		//this._light.position.y = this.height.toDouble();
		//this._light.position.z = -400.0;
		//this._light.lookAt(new Vector3(1000.0, 1000.0, 0.0));
		
		//this._light2 = new PointLight(0x999999);
		//this._light2 = new HemisphereLight(0x0000FF, 0x00FF00, intensity: 1.0);
		
		this._scene			= new Scene();
		
		this._windowResizeHandler();
		
		// Events
		this._listeners['onWindowResize']	= window.on['resize'].listen(this._windowResizeHandler);
		this._listeners['onPanMove']		= window.on[Editor.PAN_MOVE_EVENT].listen(this._panMoveHandler);
		this._listeners['onProjectUpdate']	= window.on[Project.UPDATE_EVENT].listen(this._projectUpdateHandler);
		
		// Move stuff
		this._camera.rotation.x = Math.PI;
		
		// Add stuff to scene
		//this._light.forEach((Object light) => this._scene.add(light));
		this._scene.add(this._light);
		//this._scene.add(this._light2);
		this._scene.add(this._camera);
		this._scene.add(this._mesh);
		
		// Add plane to scene
		this._plane = new Mesh
		(
			new PlaneGeometry(this._base.width.toDouble(), this._base.height.toDouble()),
			new MeshLambertMaterial(color: 0xFFFFFF)
		)
		..position.z = 600.0
		..position.x = this._base.width / 2
		..position.y = this._base.height / 2
		..rotation.y = Math.PI
		..receiveShadow = true;
		
		//this._scene.add(this._plane);
	}
	
	/*
	 * Getters
	 */
	CanvasElement	get node	=> this._renderer.domElement;
	num				get height	=> window.innerHeight;
	num				get width	=> window.innerWidth;
	
	/**
	 * Resizes canvas
	 */
	void _windowResizeHandler ([ Event event ])
	{
		this._camera..aspect = this.width / this.height
					..updateProjectionMatrix();
		
		this._renderer.setSize(this.width, this.height);
		
		this.node.attributes.remove('style'); // Keep DOM clean
		
		this._updateCamera();
	}
	
	/**
	 * Handles pan move
	 */
	void _panMoveHandler (CustomEvent event)
	{
		this.node.style.left = '${-Editor.offset.x}px';
		this.node.style.top = '${-Editor.offset.y}px';
		
		this._updateCamera();
	}
	
	/**
	 * 
	 */
	void _render ( )
	{
		this._renderer.render(this._scene, this._camera);
	}
	
	/**
	 * Moves camera and light
	 */
	void _updateCamera ([ double newZ ])
	{	
		double newX = this.width / 2 - Editor.offset.x,
			   newY = this.height / 2 - Editor.offset.y;
		
		this._camera.position.x = newX;
		this._camera.position.y = newY;
		
		//this._light.forEach((Light light) => light.position.x = newX);
		//this._light.forEach((Light light) => light.position.y = newY);
		this._light.position.x = newX;
		this._light.position.y = newY;
		
		if (newZ != null)
		{
			this._camera.position.z = newZ;
			this._light.position.z = newZ;
			//this._light.forEach((Light light) => light.position.z = newZ);
		}
		
		this._render();
	}
	
	/**
	 * Updates preview with new data
	 */
	void _projectUpdateHandler (CustomEvent event)
	{
		Map<String, Object> data = event.detail['data'];
		
		if (data == null)
		{
			return;
		}
		
		this._updateCamera();
		
		List<Map<String, Object>> layers = data['layers'];
		
		// Clear old objects
		this._scene.remove(this._mesh);
		this._mesh = new Object3D();
		this._scene.add(this._mesh);
		
		// Check layers
		if (layers.isEmpty)
		{
			return;
		}
		
		// Generate new mesh
		Object3D group = new Object3D();
		group.castShadow = true;
		group.receiveShadow = true;
		
		MeshLambertMaterial visibleLayerMaterial = new MeshLambertMaterial(color: 0xFFFFFF);
		MeshLambertMaterial invisibleLayerMaterial = new MeshLambertMaterial(color: 0xFFFFFF, opacity: .2, wireframe: true);
		MeshLambertMaterial activeMaterial = visibleLayerMaterial;
		Geometry unifiedGeometry = new Geometry();
		
		final String activeLayerId = data['activeLayerId'];
		int layerIndex = 0;
		
		// Loop through layers
		for (Map<String, Object> layer in layers)
		{
			List<Map<String, Object>> walls = layer['walls'],
									  floors = layer['floors'];
			num maxWallHeight = 0;
			
			// Loop through walls
			for (Map<String, Object> wall in walls)
			{
				Map<String, Object> first = wall['start'],
									second = wall['end'];
				
				Point start = new Point(first['x'], first['y']);
				Point end = new Point(second['x'], second['y']);
				
				num length = start.distanceTo(end);
				num thickness = (wall['thickness'] as num) * Editor.PIXELS_PER_METER;
				num height = (wall['height'] as num) * Editor.PIXELS_PER_METER;
				
				if (length == 0)
				{
					continue;
				}
				
				if (height > maxWallHeight)
				{
					maxWallHeight = height;
				}
				
				num dx = end.x - start.x;
				num dy = end.y - start.y;
				num px = (thickness / 2) * (dy / length) * -1;
				num py = (thickness / 2) * (dx / length);
				
				// Spline with cut caps
				/*
				List<Vector2> spline =
				[
					new Vector2(start.x	- px,	start.y	+ py),
					new Vector2(end.x	- px,	end.y	+ py),
					new Vector2(end.x	+ px,	end.y	- py),
					new Vector2(start.x	+ px,	start.y	- py)
				];
				*/
				
				// Spline with rectangle caps
				List<Vector2> spline =
				[
					new Vector2(start.x	+ px - py,		start.y	+ py + px),
					new Vector2(end.x	+ px + py,		end.y	+ py - px),
					new Vector2(end.x	- px + py,		end.y	- (py + px)),
					new Vector2(start.x	- (px + py),	start.y	- (py - px))
				];
				
				// Make layer opaque if camera near
				Geometry wallShape = new Shape(spline).extrude(amount: height, bevelSegments: 0);
				Mesh wallMesh = new Mesh(wallShape, activeMaterial);
				
				wallMesh.position.z = -1 * layerIndex * maxWallHeight + maxWallHeight;
				
				group.add(wallMesh);
			}
			
			// Loop through floors
			for (Map<String, Object> floor in floors)
			{
				List<Map<String, Object>> vertices = floor['vertices'];
				
				num offset = -1.0 * layerIndex * maxWallHeight;
				
				//Geometry floorShape = new Geometry();
				List<Vector3> vectors = new List<Vector3>();
				
				// Compose polygon
				for (Map<String, Object> vertex in vertices)
				{
					vectors.add(new Vector3(vertex['x'], vertex['y'], 0.0));
				}
				
				// Close polygon
				vectors.add(new Vector3(vertices.first['x'], vertices.first['y'], 0.0));
				
				// Create shape
				Geometry floorShape = new Shape(vectors).extrude(amount: 1.0);
				
				// Compose mesh
				MeshBasicMaterial floorMeterial = new MeshBasicMaterial(color: 0x555555);
				Mesh floorMesh = new Mesh(floorShape, floorMeterial);
				
				floorMesh.position.z = -1.0 * layerIndex * maxWallHeight + maxWallHeight * 2;
				
				group.add(floorMesh);
			}
			
			// Check camera pos.
			if (layer['id'] == activeLayerId)
			{
				double newCameraZ = -1.0 * layerIndex * maxWallHeight - maxWallHeight;
				
				this._moveCameraToZ(newCameraZ);
				
				activeMaterial = invisibleLayerMaterial;
				
				break;
			}
			
			layerIndex++;
		}
		
		// Compile scene
		this._mesh.add(group);
		
		this._render();
	}
	
	/**
	 * 	Moves camera to new position
	 * 	TODO: Add animation
	 */
	void _moveCameraToZ (double newCameraZ)
	{
		this._updateCamera(newCameraZ);
		
		/*
		final double activeCameraZ = this._camera.position.z;
		int step = ((activeCameraZ - newCameraZ) ~/ 10).toInt().abs(),
			m = 20;
			
		// Stop prev animation
		this._activeTimers
		..where((Timer timer) => timer != null)
		.forEach((Timer timer) => timer.cancel())
		..clear();
		
		Timer timer;
		
		if (newCameraZ > activeCameraZ)
		{
			for (int i = 0; i < step * m; i++)
			{
				timer = new Timer(new Duration(milliseconds: (i + 1)), ()
				{
					double newValue = newCameraZ - (step - i ~/ m);
					
					this._updateCamera(newValue);
				});
			}
		}
		else
		{
			for (int i = step * m; i > 0 ; i--)
			{
				timer = new Timer(new Duration(milliseconds: (i + 1)), ()
				{
					double newValue = newCameraZ + (step - i ~/ m);
					
					this._updateCamera(newValue);
				});
			}
		}
		
		this._activeTimers.add(timer);
		*/
	}
	
	// Find intersection point of two lines
	/*
	Vector2 _getIntersectionPoint (Vector2 v1, Vector2 v2,
								   Vector2 v3, Vector2 v4)
	{
		// First line
		num A1 = v2.y - v1.y,
			B1 = v1.x - v2.x,
			C1 = A1 * v1.x + B1 * v1.y;
	
		// Second line
		num A2 = v4.y - v3.y,
			B2 = v3.x - v4.x,
			C2 = A2 * v3.x + B2 * v3.y;
		
		// Delta
		num delta = A1 * B2 - A2 * B1;
		
		// Check if lines are parallel
		if (delta == 0)
		{
			return null;
		}
		
		// Return final vector
		return new Vector2((B2 * C1 - B1 * C2) / delta, (A1 * C2 - A2 * C1) / delta);
	}
	*/
	
	/*
	// Compose layer objects into unified spline
	void _compose ( )
	{
		// Generate new mesh
		/*
		Object3D group = new Object3D();
		Geometry unifiedGeometry = new Geometry();
		
		for (Wall wall in this._layer.walls)
		{
			this.merge(unifiedGeometry, new Shape(wall.spline).extrude(amount: wall.height, bevelSegments: 0));
		}
		
		group.add(new Mesh(unifiedGeometry, new MeshLambertMaterial(color: 0xFCFCFC, wireframe: true)));
		
		// Append new mesh
		this._mesh.add(group);
		*/
		
		// Copy splines
		List<Line> lines = new List<Line>();
		
		//this._layer.walls.forEach((Wall wall) => lines.add(new Line(wall.start, wall.end, wall.height, wall.spline)));
		
		// Run through all splines
		/*
		for (Line firstLine in lines)
		{
			// Lookup for connected walls at endings
			for (Line secondLine in lines)
			{
				// Check if not same wall
				if (firstLine != secondLine)
				{
					// Find intersection vectors
					Vector2 firstVector,
							secondVector;
					
					// "start-to-start"
					if (firstLine.start == secondLine.start)
					{
						
					}
					
					// "start-to-end"
					else if (firstLine.start == secondLine.end)
					{
						
					}
				
					// "end-to-end"
					else if (firstLine.end == secondLine.end)
					{
					
					}
					
					// "end-to-start"
					else if (firstLine.end == secondLine.start)
					{
						firstVector = this._getIntersectionPoint(firstLine.spline[0], firstLine.spline[1],
																 secondLine.spline[0], secondLine.spline[1]);
						secondVector = this._getIntersectionPoint(firstLine.spline[2], firstLine.spline[3],
																  secondLine.spline[2], secondLine.spline[3]);
						
						// If no intersection points
						if (firstVector == null ||
							secondVector == null)
						{
							continue;
						}
						
						// Otherwise
						else
						{
							firstLine.spline[0] = firstVector;
							firstLine.spline[3] = secondVector;
							secondLine.spline[1] = firstVector;
							secondLine.spline[2] = secondVector;
						}
					}
				}
			}
		}
		*/
		
		// Generate new mesh
		Object3D group = new Object3D();
		MeshLambertMaterial material = new MeshLambertMaterial(color: 0xFCFCFC, wireframe: true);
		Geometry unifiedGeometry = new Geometry();
		
		for (Line line in lines)
		{
			//this.merge(unifiedGeometry, new Shape(line.spline).extrude(amount: 30, bevelSegments: 0));
			/*if (line.isDrawable)
			{
				group.add(new Mesh(new Shape(line.spline).extrude(amount: line.height, bevelSegments: 0), material));
			}*/
		}
		
		//group.add(new Mesh(unifiedGeometry, new MeshLambertMaterial(color: 0xFCFCFC, wireframe: true)));
		
		// Append new mesh
		this._mesh.add(group);
	}
	*/
	
	/**
	 * Removes node
	 */
	void removeNode ( )
	{
		this.node.remove();
	}
}