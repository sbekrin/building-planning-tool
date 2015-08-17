part of planner;

/**
 * Layer class provides alot stuff
 */
class Layer extends Canvas
{
	/*
	 * Defaults
	 */
	static const DEFAULT_NAME						= 'Untitled layer',
				 
				 // Classes
				 ACTIVE_CLASS						= 'active',
				 FLOORS_CONTAINER_CLASS				= 'floors-container',
				 PROTRACTORS_CONTAINER_CLASS		= 'protractors-container',
				 WALLS_CONTAINER_CLASS				= 'walls-container',
				 ANCHORS_CONTAINER_CLASS			= 'anchors-container',
				 FURNITURE_CONTAINER_CLASS			= 'furniture-container',
				 META_OVERLAY_CONTAINER_CLASS		= 'meta-overlay-container',
				 META_BACKGROUND_CONTAINER_CLASS	= 'meta-background-container',
				 
				 // Events
				 CREATE_EVENT						= 'onLayerCreate',
				 SWITCH_EVENT						= 'onLayerSwitch',
				 UPDATE_EVENT						= 'onLayerUpdate',
				 REMOVE_EVENT						= 'onLayerRemove';
	/*
	 * Data
	 */
	String							_id;
	String							_name;
	Set/*<CanvasEditableObject>*/	_content				= new Set/*<CanvasEditableObject>*/();
    Set/*<CanvasMetaObject>*/		_meta					= new Set/*<CanvasMetaObject>*/();
	double							_offset 				= 0.0;
	int								_activeSnapshotIndex	= 0;
	List<Set/*<Object>*/>			_snapshots				= new List<Set/*<Object>*/>();
	Selection						_selectionManager		= new Selection();
	
	/*
	 * Constructor
	 */
	Layer (String name)
	{
		this._id = new DateTime.now().millisecondsSinceEpoch.toString();
		this._name = name;
		
		this._composeNode();
		
		// TODO: Issue https://code.google.com/p/dart/issues/detail?id=15787
		/*this._node..id = '$SVG_PREFIX${this._index}';
					..classes.add(EDITOR_CLASS);*/
	}
	
	/*
	 * Constructor for map object
	 */
	Layer.fromMap (Map<String, Object> data)
	{
		// Parse meta
		this._id = (data['id'] == null) ? new DateTime.now().millisecondsSinceEpoch.toString() : data['id'];
		this.name = data['name'];
		
		this._composeNode();
		
		// Parse anchors
		for (Map<String, Object> anchor in data['anchors'])
		{
			this.register(new Anchor.fromMap(anchor));
		}
		
		// Parse walls
		for (Map<String, Object> wall in data['walls'])
		{
			this.register(new Wall.fromMap(wall));
		}
		
		// Parse floors
		for (Map<String, Object> floor in data['floors'])
		{
			this.register(new Floor.fromMap(floor));
		}
	}
	
	/*
	 * Getters
	 */
	Element		get _floorsNode				=> this._node.querySelector('.$FLOORS_CONTAINER_CLASS');
	Element		get _wallsNode				=> this._node.querySelector('.$WALLS_CONTAINER_CLASS');
	Element		get _anchorsNode			=> this._node.querySelector('.$ANCHORS_CONTAINER_CLASS');
	Element		get _furnitureNode			=> this._node.querySelector('.$FURNITURE_CONTAINER_CLASS');
	Element		get _metaOverlayNode		=> this._node.querySelector('.$META_OVERLAY_CONTAINER_CLASS');
	Element		get _metaBackgroundNode		=> this._node.querySelector('.$META_BACKGROUND_CONTAINER_CLASS');
    
	Set<PlaceableCanvasObject>	get _placeable				=> this._content.where((EditableCanvasObject item) => item is PlaceableCanvasObject).toSet();
	Set<EmbeddableCanvasObject>	get _temporary				=> this._content.where((EditableCanvasObject item) => item is EmbeddableCanvasObject).toSet();
	Set<Anchor>					get _anchors				=> this._content.where((EditableCanvasObject item) => item is Anchor).toSet();
	Set<Wall>					get _walls					=> this._content.where((EditableCanvasObject item) => item is Wall).toSet();
	Set<Floor>					get _floors					=> this._content.where((EditableCanvasObject item) => item is Floor).toSet();
	Set<Protractor>				get _protractors			=> this._meta.where((MetaCanvasObject item) => item is Protractor).toSet();
	Set<Align>					get _alignments				=> this._meta.where((MetaCanvasObject item) => item is Align).toSet();
	
	Set<EditableCanvasObject>	get selection				=> this._content.where((EditableCanvasObject item) => item.isSelected).toSet();
	Set							get anchors					=> this._anchors;
	Set							get walls					=> this._walls;
	Set							get floors					=> this._floors;
	
	String				get id						=> this._id;
   	String				get name					=> this._name;
   	bool				get isActive				=> this._node.classes.contains(ACTIVE_CLASS);
   	
	Wall				get _unfinishedWall			=> this._walls.firstWhere((Wall wall) => wall.isGhost, orElse: () => null);
	Floor				get _unfinishedFloor		=> this._floors.firstWhere((Floor floor) => floor.isGhost, orElse: () => null);
	bool				get _isUnfinishedWallExists	=> this._unfinishedWall != null;
	bool				get _isUnfinishedFloorExists	=> this._unfinishedFloor != null;
	
	/*
	 * Setters
	 */
	set name (String value)
	{
		this._name = value;
		
		this.triggerUpdate();
	}
	
	/**
	 * Composes node
	 */
	void _composeNode ( )
	{
		// Append context in set order (last added = highest index)
		this._canvas.children.add(new GElement()..classes.add(FLOORS_CONTAINER_CLASS));
		this._canvas.children.add(new GElement()..classes.add(META_BACKGROUND_CONTAINER_CLASS));
		this._canvas.children.add(new GElement()..classes.add(WALLS_CONTAINER_CLASS));
		this._canvas.children.add(new GElement()..classes.add(ANCHORS_CONTAINER_CLASS));
		this._canvas.children.add(new GElement()..classes.add(FURNITURE_CONTAINER_CLASS));
		this._canvas.children.add(new GElement()..classes.add(META_OVERLAY_CONTAINER_CLASS));
		this._canvas.children.add(this._selectionManager.node);
		
		// Bind event listeners
		this._listeners['onTouchStart']			= this._node.on['touchstart'].listen(this._inputDeviceDownHandler);
		this._listeners['onMouseMove']			= this._node.on['mousemove'].listen(this._inputDeviceMoveHandler);
		this._listeners['onTouchEnd']			= this._node.on['touchend'].listen(this._inputDeviceUpHandler);
		this._listeners['onMouseDown']			= this._node.on['mousedown'].listen(this._inputDeviceDownHandler);
		this._listeners['onTouchMove']			= this._node.on['touchmove'].listen(this._inputDeviceMoveHandler);
		this._listeners['onMouseUp']			= this._node.on['mouseup'].listen(this._inputDeviceUpHandler);
		this._listeners['onMouseLeave']			= this._node.on['mouseleave'].listen(this._mouseLeaveHandler);
		this._listeners['onContextMenu']		= this._node.on['contextmenu'].listen(this._contextMenuHandler);
		this._listeners['onDragOver']			= this._node.on['dragover'].listen(this._dragOverHandler);
		this._listeners['onDrop']				= this._node.on['drop'].listen(this._dropHandler);
		this._listeners['onDragLeave']			= this._node.on['dragleave'].listen(this._dragLeaveHandler);
		this._listeners['onElementDragStart']	= window.on[InterfaceElement.DRAG_START_EVENT].listen(this._elementDragStartHandler);
		this._listeners['onElementDragEnd']		= window.on[InterfaceElement.DRAG_END_EVENT].listen(this._elementDragEndHandler);
		this._listeners['onAlignLineRequired']	= window.on[EditableCanvasObject.ALIGN_REQUIRED_EVENT].listen(this._alignLineRequiredHandler);
		this._listeners['onContentSelect']		= window.on[Selection.SELECT_EVENT].listen(this._contentSelectHandler);
		this._listeners['onContentAreaSelect']	= window.on[Selection.AREA_SELECT_EVENT].listen(this._contentAreaSelectHandler);
		this._listeners['onContentDeselect']	= window.on[Selection.DESELECT_EVENT].listen(this._contentDeselectHandler);
		
		// Send event
		window.dispatchEvent(new CustomEvent(CREATE_EVENT, detail: { 'id': this.id, 'name': this.name }));
	}
	
	/**
	 * Handles context menu event
	 */
	void _contextMenuHandler (MouseEvent event)
	{
		if (Tool.active == Tool.WALL)
		{
			this._unregisterUnfinishedWall();
			
			this.triggerUpdate();
		}
		else if (Tool.active == Tool.FLOOR)
		{
			this._finishUnfinishedFloor();
			
			this.triggerUpdate();
		}
		
		event.preventDefault();
		event.stopPropagation();
	}
	
	/**
	 * Handles mouse down and touch start events
	 */
	void _inputDeviceDownHandler (Event event)
	{
		Point point;
		
		// If click handled
		if (event is MouseEvent)
		{
			// Accept left mouse click only	
			if (event.which != 1)
			{
				return;
			}
			
			point = event.client;
		}
		
		// If tap handled
		else if (event is TouchEvent)
		{
			point = event.touches.first.client;
		}
		
		// Start selection
		if (Tool.active == Tool.SELECT)
		{
			// One finger touch only
			if ((event is TouchEvent) &&
				 event.touches.length != 1)
			{
				return;
			}
			
			this._selectionManager.startSelectionAt(PointDoubleToInt(this._getNormalizedPoint(point)));
		}
		
		// Start wall
		else if (Tool.active == Tool.WALL)
		{
			point = this._getSnappedPoint(point);
			
			this._proceedWallDrawLogicAt(point);
			
			Wall wall;
			
			if (this.isUnique(wall = new Wall(point, null)))
			{
				this.register(wall);
			}
			
			/*
			// Create protractor
			Protractor protractor = new Protractor(this._anchors.last,
													this.queryWallsAt(this._anchors.last.center));
			
			if (this.isUnique(protractor))
			{
				this.register(protractor);
			}
			*/
		}
		
		// Start floor
		else if (Tool.active == Tool.FLOOR)
		{
			point = this._getSnappedPoint(point);
			
			// Check if undone floor exists
			if (this._isUnfinishedFloorExists)
			{
				Floor floor = this._floors.last;
				
				// Check for loop
				if (floor.firstVertex == point)
				{
					floor.finish();
					floor.hideArea();
				}
				else
				{
					Anchor anchor;
					
					if (this.isUnique(anchor = new Anchor(point)))
					{
						this.register(anchor);
					}
					
					floor.lineTo(point);
				}
			}
			
			// Otherwise create new
			else
			{
				Anchor anchor;
                					
				if (this.isUnique(anchor = new Anchor(point)))
				{
					this.register(anchor);
				}
				
				Floor floor = new Floor(point);
				
				floor.showArea();
				
				this.register(floor);
			}
		}
		
		event.preventDefault();
	}
	
	/**
	 * Handles mouse move and touch move events
	 */
	void _inputDeviceMoveHandler (Event event)
	{
		Point point;
		
		// If mouse handled
		if (event is MouseEvent)
		{
			point = event.client;
		}
		
		// If touch handled
		else if (event is TouchEvent)
		{
			point = event.touches.first.client;
		}
		
		// Clear align stuff
		this.unregisterAll(this._alignments);
		
		// Redraw selection rectangle
		if (Tool.active == Tool.SELECT)
		{
			if (this._selectionManager.isActive)
			{
				point = this._getNormalizedPoint(point);
				
				this._selectionManager.update(PointDoubleToInt(point));
			}
		}

		// Update wall
		else if (Tool.active == Tool.WALL)
		{
			// Get point
			point = this._getSnappedPoint(point);
			
			// Update ghost wall
			if (this._isUnfinishedWallExists)
			{
				// Update protrcator for new wall
				/*
				if (this._protractors.isNotEmpty)
				{
					this._protractors.last.update();
				}
				*/
				
				this._walls.last.endPoint = point;
				
				this.triggerUpdate();
			}
			
			// Remove collapsed walls
			this._removeCollapsedWalls();
		}
		
		// Update floor
		else if (Tool.active == Tool.FLOOR)
		{
			point = this._getSnappedPoint(point);
			
			if (this._isUnfinishedFloorExists)
			{
				this._unfinishedFloor.moveTo(point);
				
				this.triggerUpdate();
			}
		}
		
		event.preventDefault();
	}
	
	/**
	 * Handles mouse up and touch end events
	 */
	void _inputDeviceUpHandler (Event event)
	{
		Point point;
		
		// If click handled
		if (event is MouseEvent)
		{
			// Accept left mouse click only
			if (event.which != 1)
			{
				return;
			}
			
			point = event.client;
		}
		
		// If tap handled
		else if (event is TouchEvent)
		{
			point = event.changedTouches.first.client;
		}
		
		// Selection
		if (Tool.active == Tool.SELECT)
		{
			this._selectionManager.endSelection();
		}
		
		// Wall drawing
		else if (Tool.active == Tool.WALL)
		{
			// Only for touch event
			if (event is! TouchEvent)
			{
				return;
			}
			
			point = this._getSnappedPoint(point);
			
			this._proceedWallDrawLogicAt(point);
		}
		
		event.preventDefault();
	}
	
	/**
	 * Handles mouse leave event
	 */
	void _mouseLeaveHandler (MouseEvent event)
	{
		if (Tool.active == Tool.WALL)
		{
			this._unregisterUnfinishedWall();
		}
	}
	
	/**
	 * Handles object drag enter
	 */
	void _dragOverHandler (MouseEvent event)
	{
		this.unregisterAll(this._alignments);
		
		if (!event.dataTransfer.types.contains(InterfaceElement.DATA_TRANSFER_TYPE))
		{
			return;
		}
		
		// If wall or door
		if (this._temporary.isNotEmpty /*&&
			this._temporary.last.isGhost*/)
		{
			Point target = this._getNormalizedPoint(event.client);
			Door door = this._temporary.last;
			
			door.pivot = target;
			
			// Query first wall at this point
			try
			{
				Wall wall = this._walls.firstWhere((Wall wall) =>
														 wall.isRelatedPoint(target, Wall.SNAP_FORCE));
				
				if (wall != null)
				{
					door.angle = wall.angleFromHorizontalAxis;
				}
				else
				{
					door.angle = new Angle.fromDegrees(0);
				}
			}
			catch (e) { } // No related walls
		}
		
		event.preventDefault();
	}
	
	/**
	 * Handles objects drop
	 */
	void _dropHandler (MouseEvent event)
	{
		if (this._temporary.isNotEmpty /*&&
        	this._temporary.last.isGhost*/)
		{
			this._temporary.last
			..pivot = this._getSnappedPoint(event.client)
			..isGhost = false;
		}
		
		String data = event.dataTransfer.getData(InterfaceElement.DATA_TRANSFER_TYPE);
	}
	
	/**
	 * Handles objects drag leave
	 */
	void _dragLeaveHandler (MouseEvent event)
	{
		if (this._temporary.isNotEmpty /*&&
        	this._temporary.last.isGhost*/)
		{
			this._temporary.last.pivot = new Point(0, 0);	
		}
	}
	
	/**
	 * Handles any interface element movement
	 */
	void _elementDragStartHandler (CustomEvent event)
	{
		Map<String, Object> object = event.detail;
		
		if (object['type'] == CanvasObject.CLASS)
		{
			if (object['class'] == Door.CLASS)
			{
				Door door = new Door(new Point(0, 0), new Angle.fromDegrees(0));
				
				door.isGhost = true;
				
				this.register(door);
			}
		}
	}
	
	/**
	 * Handles any interface element movement
	 */
	void _elementDragEndHandler (CustomEvent event)
	{
		if (this._temporary.isNotEmpty /*&&
            this._temporary.last.isGhost*/)
		{
			this.unregister(this._temporary.last);	
		}
    }
	
	/**
	 * Handles align line call
	 */
	void _alignLineRequiredHandler (CustomEvent event)
	{
		Point base = event.detail['base'];
		int type = event.detail['type'];
		
		Align align;
		
		if (this.isUnique(align = new Align(type, base)))
		{
			this.register(align);
		}
	}
	
	/**
	 * Handles content object selection
	 */
	void _contentSelectHandler (CustomEvent event)
	{
		if (!Hotkey.active.contains(Key.CTRL))
		{
			this.deselectAll();
		}
		
		List<int> hashCodeList = event.detail['content'];
		
		Set<EditableCanvasObject> objects = this._content.where((EditableCanvasObject object) =>
																					  hashCodeList.contains(object.hashCode)).toSet();
		
		this.toggleSelectionAll(objects);
	}
	
	/**
	 * Handles content area selection
	 */
	void _contentAreaSelectHandler (CustomEvent event)
	{
		if (!Hotkey.active.contains(Key.CTRL))
		{
			this.deselectAll();
		}
		
		Rectangle area = new Rectangle.fromPoints(event.detail['start'], event.detail['end']);
		
		this.toggleSelectionAll(this.queryObjectsInArea(area));
	}
	
	/**
	 * Handles content deselection
	 */
	void _contentDeselectHandler (CustomEvent event)
	{
		this.deselectAll(event.detail['content'].toSet());
	}
	
	/**
	 * Removes zero-walls
	 */
	void _removeCollapsedWalls ( )
	{
		this.unregisterAll(this._walls.where((Wall wall) =>
												   wall.isCollapsed && wall.isNotGhost).toSet());
	}
	
	/**
	 * Finishes last created ghost wall
	 */
	void _finishUnfinishedWallAt (Point point)
	{
		if (this._isUnfinishedWallExists)
		{
			// We did not saved wall so far
			Wall unfinishedWall = this._walls.last;
			
			unfinishedWall.finishAt(point);
			
			// Remove ghost wall
			this.unregister(unfinishedWall);
			
			// And replace it with new one
			if (this.isUnique(unfinishedWall))
			{
				this.register(unfinishedWall);
			}
		}
		else
		{
			// Create snapshot on first click
			this.createSnapshot();
		}
		
		// Create point if not duplicate
		Anchor anchor;
		
		if (this.isUnique(anchor = new Anchor(point)))
		{
			this.register(anchor);
		}
	}
	
	/**
	 * Removes last ghost wall if exists
	 */
	void _unregisterUnfinishedWall ( )
	{
		if (this._isUnfinishedWallExists)
		{
			this.unregister(this._unfinishedWall);
		}
	}
	
	/**
	 * Finishes ghost floor if exsits
	 */
	void _finishUnfinishedFloor ( )
	{
		if (this._isUnfinishedFloorExists)
		{
			Floor floor = this._unfinishedFloor;
			
			floor..finish()
				 ..hideArea();
			
			if (floor.isCollapsed)
			{
				this.unregister(floor);
			}
		}
	}
	
	/**
	 * Splits walls at set point
	 */
	void _splitWallsAt (Point point)
	{
		Set<Wall> targets = this._walls.where((Wall wall) =>
													wall.isRelatedPoint(point)).toSet();
		
		for (Wall target in targets)
		{
			List<Wall> replacement = target.splitAt(point);
            		
    		if (this.isUnique(replacement[0]) &&
    			this.isUnique(replacement[1]))
    		{
    			this.registerAll(replacement.toSet());
    			this.unregister(target);
    		}
		}
	}
	
	/**
	 * Returns new point with given offset
	 * TODO: Include zoom
	 */
	Point _getNormalizedPoint (Point base)
	{
		// Exclude offset
		return base -= PointIntToDouble(Editor.offset);
	}
	
	/**
	 * Returns new point with given snapping stuff
	 */
	Point _getSnappedPoint (Point base)
	{
		base = this._getNormalizedPoint(base);
		
		// Check anchors first
		if (Settings.get('anchor-snap'))
		{
			// Try direct snap at first
			/*
			try
			{
				return this._anchors
				.firstWhere((Anchor anchor) =>
									anchor.isSnapPoint(base))
				.getSnapPoint(base);
			}
			catch (e) { }
			*/
			
			// Sort points by distance to base before snap point calculcation
			List<Anchor> anchors = this._anchors.toList();
			
			anchors.sort((Anchor a, Anchor b) =>
					   			 a.center.squaredDistanceTo(base).compareTo(b.center.squaredDistanceTo(base)));
			
			// Horizal axis
			Point horizalTarget;
			
			try
			{
				horizalTarget = anchors
				.firstWhere((Anchor anchor) =>
									anchor.isHorizalSnapPoint(base))
				.getHorizalSnapPoint(base);
			}
			catch (e) { }
			
			if (horizalTarget != null)
			{
				Align align;
				
				if (this.isUnique(align = new Align(Align.HORIZAL, horizalTarget)))
				{
					this.register(align);
				}
			}
			
			// Vertical axis
			Point verticalTarget;
			
			try
         {
				verticalTarget = anchors
				.firstWhere((Anchor anchor) =>
									anchor.isVerticalSnapPoint(base))
				.getVerticalSnapPoint(base);
         }
			catch (e) { }
			
			if (verticalTarget != null)
			{
				Align align;
				
				if (this.isUnique(align = new Align(Align.VERTICAL, verticalTarget)))
				{
					this.register(align);
				}
			}
			
			// Compose point
			if (horizalTarget != null &&
				verticalTarget != null)
			{
				return new Point(horizalTarget.x, verticalTarget.y);
			}
			else if (horizalTarget != null &&
					 verticalTarget == null)
			{
				return horizalTarget;
			}
			else if (verticalTarget != null &&
					 horizalTarget == null)
			{
				return verticalTarget;	
			}
		}
			
		// Check wall snapping
		if (Settings.get('wall-snap'))
		{
			try
			{
				return this._walls
				.firstWhere((Wall wall) =>
								  wall.isNotGhost && wall.isSnapPoint(base))
				.getSnapPoint(base);
			}
			catch (e) { }
		}
		
		// TODO: Check grid snapping
		/*
		if (Settings.get('grid-snap'))
		{
			
		}
		*/
		
		// If no snap point found
		return base;
	}
	
	/**
	 * Regular wall drawing logic
	 */
	void _proceedWallDrawLogicAt (Point point)
	{
		// Finish last wall
		this._finishUnfinishedWallAt(point);
			
		// Split walls
		this._splitWallsAt(point);
			
		// Create snapshot
		this.createSnapshot();
	}
	
	/**
	 * Regular floor drawing logic
	 */
	void _proceedFloorDrawLogicAt (Point point)
	{
		
	}
	
	/**
	 * Checks selection and creates special menu section if required
	 * TODO: Move this to application class
	 */
	void _checkSpecialMenuSection ( )
	{
		// Check if selection is empty
		if (this.selection.isEmpty)
		{
			window.dispatchEvent(new CustomEvent(ContextMenuSection.CLOSE_EVENT, detail: { 'ids': [ 'Modify' ]}));
			
			return;
		}
		
		// Prepare common section
		ContextMenuSection section = new ContextMenuSection('Modify', [
			new MenuSectionGroup('Common', [
				new MenuSectionGroupLabelItem('Remove', Action.alias('editRemove'), icon: new Icon('trash'), vertical: true)
			])
		]);
		
		// Collect selection types
		Set<String> selectionTypes = new Set<String>();
		
		this.selection.forEach((EditableCanvasObject object) =>
													  selectionTypes.add(object.runtimeType.toString()));
		
		// Check if they are same
		Set<Type> types = new Set<Type>();
		
		for (EditableCanvasObject object in this.selection)
		{
			types.add(object.runtimeType);
		}
		
		// Check anchors
		if (types.contains(Anchor))
		{
			// TODO: Add "smooth" feature
			// TODO: Add "cut" feature
		}
		
		// Check walls
		if (types.contains(Wall))
		{
			List<Wall> walls = this.selection.where((EditableCanvasObject object) =>
																		  object is Wall).toList();
			
			num thickness = (walls.length > 1) ? 0.0 : walls.first.thickness;
			num height = (walls.length > 1) ? 0.0 : walls.first.height;
			
			section.register(new MenuSectionGroup('Wall', [
				new MenuSectionGroupLabelItem('Reverse', Action.alias('wallReverse')),
				new MenuSectionGroupNumberInput('Thickness', (num value) => walls.forEach((Wall wall) =>
																								wall.thickness = value), base: thickness, min: 0.1, max: 2.5, step: 0.05),
				new MenuSectionGroupNumberInput('Height', (num value) => walls.forEach((Wall wall) =>
																							 wall.height = value), base: height, min: 0.5, step: 0.05)
			]));
		}
		
		// Check floor
		if (types.contains(Floor))
		{
			section.register(new MenuSectionGroup('Color', [
			
			]));				
		}
		
		// Show special section finally
		window.dispatchEvent(new CustomEvent(ContextMenuSection.CREATE_EVENT, detail: { 'section': section }));
	}
		
	/**
	 * Checks for canvas objects uniqueness by it's coordinates
	 * Actually objects are duplicates then placed 
	 */
	bool isUnique (CanvasObject object)
	{
		// Check anchor
		if (object is Anchor)
		{
			try
			{
				this._anchors
				.firstWhere((Anchor anchor) =>
								   (anchor.center == object.center));
				
				return false;
			}
			catch (e) { return true; }
		}
		
		// Check wall
		else if (object is Wall)
		{
			try
			{
				this._walls
				.where((Wall wall) => wall.isNotGhost)
				.firstWhere((Wall wall) => (wall.startPoint == object.startPoint	&& wall.endPoint == object.endPoint) ||
										   (wall.startPoint == object.endPoint		&& wall.endPoint == object.startPoint));
				
				return false;
			}
			catch (e) { return true; }
		}
		
		// Check protractor
		else if (object is Protractor)
		{
			try
			{
				this._protractors
				.firstWhere((Protractor protractor) =>
									   (protractor.center == object.center));
				
				return false;
			}
			catch (e) { return true; }
		}
		
		// Check align
		else if (object is Align)
		{
			try
			{
				this._alignments
				.firstWhere((Align align) =>
								   align.base == object.base &&
								   align.type == object.type);
				
				return false;
			}
			catch (e) { return true; }
		}
		
		// If undefined object passed
		throw new Exception('Undefined object being checked as duplicate');
	}
	
	/**
	 * Checks for canvas object dublicate
	 */
	bool isNotUnique (CanvasObject object)
	{
		return !isUnique(object);
	}
	
	/**
	 * Collects data to map object
	 */
	Map<String, Object> toMap ( )
	{
		Map<String, Object> data = new Map<String, Object>();
		
		// Meta
		data['id'] = this.id;
		data['name'] = this.name;
		data['offset'] = this._offset;
		
		// Collect anchors
		List<Map<String, int>> anchorsData = new List<Map<String, int>>();
		
		this._anchors.forEach((Anchor anchor) =>
									  anchorsData.add(anchor.toMap()));
		
		data['anchors'] = anchorsData;
		
		// Collect walls
		List<Map<String, Object>> wallsData = new List<Map<String, Object>>();
		
		this._walls.forEach((Wall wall) =>
								  wallsData.add(wall.toMap()));
		
		data['walls'] = wallsData;
		
		// Collect floors
		List<Map<String, Object>> floorsData = new List<Map<String, Object>>();
		
		this._floors.forEach((Floor floor) =>
									floorsData.add(floor.toMap()));
		
		data['floors'] = floorsData;
		
		// Return data
		return data;
	}
	
	/**
	 * Triggers update event
	 */
	void triggerUpdate ( )
	{
		// Send UPDATE_EVENT to preview
		window.dispatchEvent(new CustomEvent(UPDATE_EVENT, detail: { 'id': this.id }));
	}
	
	/**
	 * Registers object
	 */
	void register (CanvasObject object)
	{
		Element container;
		
		// If meta stuff
		if (object is MetaCanvasObject)
		{
			this._meta.add(object);
			
			// If protractor
			if (object is Protractor)
			{
				container = this._metaBackgroundNode;
			}
			
			// If ruler
			else if (object is Ruler)
			{
				container = this._metaOverlayNode;
			}
			
			// If align
			else if (object is Align)
			{
				container = this._metaOverlayNode;
			}
			
			// Uh?
			else
			{
				throw new ArgumentError('Undefined meta object being registered');
			}
		}
		
		// If editable stuff
		else if (object is EditableCanvasObject)
		{
			this._content.add(object);
			
			// If anchor
			if (object is Anchor)
			{
				container = this._anchorsNode;
			}
			
			// If wall
			else if (object is Wall)
			{
				container = this._wallsNode;
			}
			
			// If floor
			else if (object is Floor)
			{
				container = this._floorsNode;
			}
			
			// if door
			else if (object is Door)
			{
				container = this._furnitureNode;
			}
			
			// Oh!
			else
			{
				throw new ArgumentError('Undefined editable object being registered');
			}
			
			this.triggerUpdate();
		}
		
		// Ugh...
		else
		{
			throw new ArgumentError('Undefined object type being registered');
		}
		
		container.children.add(object.node);
	}
	
	/**
	 * Registers bunch if objects
	 */
	void registerAll (Set<CanvasObject> objects)
	{
		objects.forEach((CanvasObject object) =>
									this.register(object));
	}
	
	/**
	 * Unregisters object
	 */
	void unregister (CanvasObject object)
	{
		object.removeNode();
		
		// If meta object
		if (object is MetaCanvasObject)
		{
			this._meta.remove(object);
		}
		
		// If editable object
		else if (object is EditableCanvasObject)
		{
			// If anchor
			if (object is Anchor)
			{
				// Delete related walls
				this.queryWallsAt(object.center)
					.forEach((Wall wall) =>
								   this.unregister(wall));
				
				// Delete related protractor
				Protractor protractor;
				
				if ((protractor = this.queryProtractor(object.center)) != null)
				{
					this.unregister(protractor);
				}
			}
			
			this._content.remove(object);
		}
		
		// Uh?
		else
		{
			throw new Exception('Undefined object being unregistered');
		}
	}
	
	/**
	 * Unregisters bunch of objects
	 */
	void unregisterAll (Set<CanvasObject> objects)
	{
		// Prevent concurrent modificate exception
		List<CanvasObject> objectList = objects.toList();
		
		for (int i = 0; i < objectList.length; i++)
		{
			this.unregister(objectList[i]);
		}
	}
	
	/**
	 * Selects item
	 */
	void select (EditableCanvasObject object)
	{
		// If already selected
		if (object.isSelected)
		{
			return;
		}
		
		object.select();
		
		// Anchor
		if (object is Anchor)
		{
			this._anchorsNode.children..remove(object.node)
									  ..add(object.node);
			
			Protractor protractor;
			
			if (this.isUnique(protractor = new Protractor(object, this.queryWallsAt(object.center))))
			{
				this.register(protractor);
			}
		}
		
		// Wall
		else if (object is Wall)
		{
			this._wallsNode.children..remove(object.node)
									..add(object.node);
			
			object.showRuler();
		}
		
		// Floor
		else if (object is Floor)
		{
			object.showArea();
		}
		
		// Door
		else if (object is Door)
		{
			
		}
		
		// wtf
		else
		{
			throw new Exception('Undefined item being selected');
		}
		
		this._checkSpecialMenuSection();
	}
	
	/**
	 * Select bunch of items
	 */
	void selectAll ([ Set<EditableCanvasObject> objects ])
	{
		if (objects == null)
		{
			objects = this._content;
		}
		
		objects.forEach((EditableCanvasObject item) =>
											  this.select(item));
	}
	
	/**
	 * Deselect item
	 */
	void deselect (EditableCanvasObject object)
	{
		// Check if not selected
		if (object.isNotSelected)
		{
			return;
		}
		
		object.deselect();
		
		// Anchor
		if (object is Anchor)
		{
			Protractor protractor;
			
			if ((protractor = this.queryProtractor(object.center)) != null)
			{
				this.unregister(protractor);
			}
		}
		
		// Wall
		else if (object is Wall)
		{
			object.hideRuler();
		}
		
		// Floor
		else if (object is Floor)
		{
			object.hideArea();
		}
		
		this._checkSpecialMenuSection();
	}
	
	/**
	 * Deselect bunch of items
	 */
	void deselectAll ([ Set<EditableCanvasObject> objects ])
	{
		if (objects == null)
		{
			objects = this._content;
		}
		
		this.selection
		.forEach((EditableCanvasObject item) =>
									   this.deselect(item));
	}
	
	/**
	 * Toggles selection of item
	 */
	void toggleSelection (EditableCanvasObject object)
	{
		object.isSelected ? this.deselect(object) : this.select(object);
	}
	
	/**
	 * Toggles selection of bunch items
	 */
	void toggleSelectionAll ([ Set<EditableCanvasObject> objects ])
	{
		if (objects == null)
		{
			objects = this._content;
		}
		
		objects.forEach((EditableCanvasObject object) =>
											  this.toggleSelection(object));
	}
	
	/**
	 * Removes selection
	 */
	void removeSelection ( )
	{
		if (Tool.active != Tool.SELECT)
		{
			return;
		}
		
		this.unregisterAll(this.selection);
		this.createSnapshot();
		this.triggerUpdate();
		
		this._checkSpecialMenuSection();
	}
	
	/**
	 * Returns objects in set area
	 */
	Set<EditableCanvasObject> queryObjectsInArea (Rectangle area)
	{
		return this._content
		.where((EditableCanvasObject object) =>
									 object.inRange(area))
		.toSet();
	}
	
	/**
	 * Returns only point related to base
	 */
	Anchor queryAnchor (Point targetPoint)
	{
		try
		{
			return this._anchors
			.firstWhere((Anchor anchor) =>
							   (anchor.center == targetPoint));
		}
		catch (e) { }
	}
	
	/**
	 * Returns any walls related to set point
	 */
	Set<Wall> queryWallsAt (Point targetPoint)
	{
		return this._walls
		.where((Wall wall) =>
					(wall.startPoint == targetPoint || wall.endPoint == targetPoint))
		.toSet();
	}
	
	/**
	 * Returns protractor placed on set point
	 */
	Protractor queryProtractor (Point targetPoint)
	{
		try
		{
			return this._protractors
			.firstWhere((Protractor protractor) =>
								   (protractor.center == targetPoint));
		}
		catch (e) { }
	}
	
	/**
	 * Clears layer content
	 */
	void clear ( )
	{
		this.unregisterAll(this._content);
	}
	
	/**
	 * Creates snapshot
	 */
	void createSnapshot ( )
	{
		// Save snapshot
		this._snapshots.add(new Set.from(this._content));
		
		// Set as active
		this._activeSnapshotIndex = this._snapshots.length - 1; // this._snapshots.indexOf(this._snapshots.last);
	}
	
	/**
	 * Rollbacks set count of changes
	 */
	void rollback (int steps)
	{
		// If not possible to rollback
		if (this._snapshots.isEmpty ||
			this._activeSnapshotIndex + steps < 0 ||
			this._activeSnapshotIndex + steps >= this._snapshots.length)
		{
			return;
		}
		
		this.clear();
		
		this.registerAll(this._snapshots.elementAt(this._activeSnapshotIndex += steps));
	}
	
	/**
	 * Shows layer
	 */
	void show ( )
	{
		/*
		this._listeners
		.forEach((String name, StreamSubscription listener) =>
												  listener.resume());
		*/
		
		this._node.classes.add(ACTIVE_CLASS);
	}
	
	/**
	 * Hides layer
	 */
	void hide ( )
	{
		/*
		this._listeners
		.forEach((String name, StreamSubscription listener) =>
												  listener.pause());
		*/
		
		this._node.classes.remove(ACTIVE_CLASS);
	}
	
	/**
	 * Removes layer
	 */
	void remove ( )
	{
		super.removeNode();
		
		window.dispatchEvent(new CustomEvent(REMOVE_EVENT, detail: { 'id': this.id }));
	}
}