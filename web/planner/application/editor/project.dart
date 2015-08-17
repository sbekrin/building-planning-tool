part of planner;

/**
 * Project class
 * 
 * TODO: Prevent selection then panning via mouse + space / 2 fing. touch
 */
class Project extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const MAX_OFFSET_LIMIT			= 100,
				 
				 // Classes
				 CONTENT_CONTAINER_CLASS	= 'editor-content',
				 LAYER_CONTAINER_CLASS		= 'editor-content-layers',
				 GRID_CONTAINER_CLASS		= 'editor-content-grid',
				 PREVIEW_CONTAINER_CLASS	= 'editor-content-preview',
				 PAN_CLASS					= 'move',
				 
				 // Events
				 UPDATE_EVENT				= 'onProjectUpdate',
				 
				 // Size
				 DEFAULT_WIDTH				= 2560,
                 DEFAULT_LENGTH				= 1440;
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners					= new Map<String, StreamSubscription>();
	String							_name;
	Rectangle						_base;
	//DateTime						_updated					= new DateTime.now();
	List<Layer>						_layers						= new List<Layer>();
	//Preview							_preview;
	Grid							_grid;
	Map<int, Touch>					_touches					= new Map<int, Touch>();
	bool							_isPanEnabled				= true;
	bool							_isZoomEnabled				= true;
	bool							_isResizeEnabled			= true;
	//bool							_isSelectionEnabled			= true;
	Point<int>						_panStartedAt;
	Point<int>						_panStartedOffset;
	int								_lastLayerIndex				= 0;
	double							_scaleLevel					= 1.0;
	
	/*
	 * Constructor
	 */
	Project (Rectangle base, String name)
	{
		this._base = base;
		this._name = name;
		
		this._setup();
		
		this._synchronizeLayerWithWidget(this.createNewLayer());
	}
	
	/*
	 * Existed project constructor
	 */
	Project.fromMap (String jsonString)
	{
		// TODO: Move higher
		Map<String, Object> data = JSON.decode(jsonString);
			
		// Collect meta
		Map<String, Object> size = data['size'];
		this._base = new Rectangle(0, 0, size['width'], size['length']);
		this._name = data['name'];
		this._setup();
		
		// Coolect layers
		for (Map<String, Object> layer in data['layers'])
		{
			this.register(new Layer.fromMap(layer));
		}
		
		// Prevent desynchronization with layers widget
		this._synchronizeLayerWithWidget(data['activeLayerId']);
		
		// Select latest layer
		this.switchToLayer(data['activeLayerId']);
		
		// Set last layer index
		this._lastLayerIndex = this._layers.length;
	}
	
	/*
	 * Getters
	 */
	static Rectangle get size				=> new Rectangle(0, 0, DEFAULT_WIDTH, DEFAULT_LENGTH);
	
	Element		get _layerContainer			=> this._node.querySelector('.$LAYER_CONTAINER_CLASS');
	Element		get _contentContainer		=> this._node.querySelector('.$CONTENT_CONTAINER_CLASS');
	Element		get _gridContainer			=> this._node.querySelector('.$GRID_CONTAINER_CLASS');
	Element		get _previewContainer		=> this._node.querySelector('.$PREVIEW_CONTAINER_CLASS');
	List<Layer>	get layers					=> this._layers;
	Layer		get activeLayer				=> this._layers.firstWhere((Layer layer) => layer.isActive, orElse: () => this._layers.first);
	String		get activeLayerId			=> this.activeLayer.id;
	Rectangle	get viewport				=> new Rectangle(this.transform['x'], this.transform['y'], this.width, this.height);
	int			get width					=> int.parse(this._contentContainer.style.width.replaceAll('px', ''));
	int			get height					=> int.parse(this._contentContainer.style.height.replaceAll('px', ''));
	bool		get isGridEnabled			=> this._grid != null;
	//bool		get isPreviewEnabled		=> this._preview != null;
	bool		get isPanEnabled			=> this._isPanEnabled;
	bool		get isZoomEnabled			=> this._isZoomEnabled;
	bool		get isResizeEnabled			=> this._isResizeEnabled;
	
	Map<String, int> get transform
	{
		RegExp expression = new RegExp(r"^translate3d\((-?\d+)px,\s+(-?\d+)px,\s+(-?\d+)px\)$");
		Iterable<Match> matches = expression.allMatches(this._contentContainer.style.transform);
		
		return
		{
			'x': int.parse(matches.first[1]),
			'y': int.parse(matches.first[2]),
			'z': int.parse(matches.first[3])
		};
	}
	
	/*
	 * Setters
	 */
	set width (int width)	=> this._contentContainer.style.width = '${width}px';
	set height (int height)	=> this._contentContainer.style.height = '${height}px';
	
	/**
	 * Setup layer
	 */
	void _setup ( )
	{
		// Create node
		this._node = new Element.html('''
			<section>
				<div class="$CONTENT_CONTAINER_CLASS">
					<div class="$PREVIEW_CONTAINER_CLASS"></div>
					<div class="$GRID_CONTAINER_CLASS"></div>
					<div class="$LAYER_CONTAINER_CLASS"></div>
				</div>
			</section>
		''');
		
		// Fit to base
		this._fitTo(this._base);
		
		// Event listeners
		this._listeners['onTouchStart']		= this._node.on['touchstart'].listen(this._touchStartHandler);
		this._listeners['onTouchMove']		= this._node.on['touchmove'].listen(this._touchMoveHandler);
		this._listeners['onTouchEnd']		= this._node.on['touchend'].listen(this._touchEndHandler);
		this._listeners['onMouseDown']		= this._node.on['mousedown'].listen(this._mouseDownHandler);
		this._listeners['onMouseMove']		= this._node.on['mousemove'].listen(this._mouseMoveHandler);
		this._listeners['onMouseUp']		= this._node.on['mouseup'].listen(this._mouseUpHandler);
		//this._listeners['onMouseWheel']		= this._node.on['mousewheel'].listen(this._mouseWheelHandler);
		this._listeners['onLayerSelect']	= window.on[Layer.SWITCH_EVENT].listen(this._layerSwitchHandler);
		this._listeners['onLayerUpdate']	= window.on[Layer.UPDATE_EVENT].listen(this._layerUpdateHandler);
		this._listeners['onToolChange']		= window.on[Tool.CHANGE_EVENT].listen(this._toolChangeHandler);
		
		// Append grid
		this.enableGrid();
		
		// Append preview
		//this.enablePreview();
		
		// Compose interface block
		this._compose();
	}
	
	/**
	 * Handles touch start
	 */
	void _touchStartHandler (TouchEvent event)
	{
		event.preventDefault();
		
		// 2 fingers for panning
		if (event.touches.length != 2)
		{
			return;
		}
		
		// Dispatch PAN_START event
		window.dispatchEvent(new CustomEvent(Editor.PAN_START_EVENT));
		
		// Calc points
		Point firstTouchPoint = event.touches.first.client;
		Point secondTouchPoint = event.touches.last.client;
		Point middleTouchPoint = new Point((firstTouchPoint.x + secondTouchPoint.x) ~/ 2,
										   (secondTouchPoint.y + secondTouchPoint.y) ~/ 2);
		
		// Set start pan point
		this._panStartedAt = middleTouchPoint;
		this._panStartedOffset = new Point(this.viewport.left, this.viewport.top);
		
		event.stopPropagation();
	}
	
	/**
	 * Handles touch move
	 */
	void _touchMoveHandler (TouchEvent event)
	{
		event.preventDefault();
		
		// 2 fingers for panning
		if (event.touches.length != 2)
		{
			return;
		}
		
		// Calculate new point
		Point firstTouchPoint = event.touches.first.client;
		Point secondTouchPoint = event.touches.last.client;
		Point middleTouchPoint = new Point((firstTouchPoint.x + secondTouchPoint.x) ~/ 2,
										   (secondTouchPoint.y + secondTouchPoint.y) ~/ 2);
		
		this._proceedPanning(middleTouchPoint);
	}
	
	/**
	 * Handles touch end
	 */
	void _touchEndHandler (TouchEvent event)
	{
		event.preventDefault();
	}
	
	/**
	 * Handles mouse down event
	 */
	void _mouseDownHandler (MouseEvent event)
	{
		// If panning is disabled
		if (!this._isPanEnabled)
		{
			return;
		}
		
		// Allow only mid-mouse and mouse + space
		if (event.which == 2 ||
			event.which == 1 && Hotkey.active.contains(Key.SPACE))
		{
			//this.toggleFeature(selection: false);
		}
		else
		{
			return;
		}
		
		// Dispatch PAN_START event
		window.dispatchEvent(new CustomEvent(Editor.PAN_START_EVENT));
		
		// Set start pan point
		this._panStartedAt = event.client;
		this._panStartedOffset = new Point(this.viewport.left, this.viewport.top);
		
		// Change cursor
		this._node.classes.add(PAN_CLASS);
		
		event.preventDefault();
		event.stopPropagation();
	}
	
	/**
	 * Handles mouse move event
	 */
	void _mouseMoveHandler (MouseEvent event)
	{
		// Exit if not panning
		if (!this._isPanEnabled || 
			this._panStartedAt == null)
		{
			return;
		}
		
		this._proceedPanning(event.client);
	}
	
	/**
	 * Handles mouse up event
	 */
	void _mouseUpHandler (MouseEvent event)
	{
		// Exit if not panning
		if (!this._isPanEnabled ||
			this._panStartedAt == null)
		{
			return;
		}
		
		// Dispatch PAN_END event
		window.dispatchEvent(new CustomEvent(Editor.PAN_END_EVENT));
		
		// Clear points
		this._panStartedAt = null;
		this._panStartedOffset = null;
		
		// Remove move cursor
		this._node.classes.remove(PAN_CLASS);
	}
	
	/**
	 * Handles mousewheel
	 */
	void _mouseWheelHandler (WheelEvent event)
	{
		// If zooming is disabled
		if (!this._isZoomEnabled)
		{
			return;
		}
		
		// Zoom in
		if (event.deltaY < 0)
		{
			this.zoomIn();
		}
		
		// Zoom out
		else if (event.deltaY > 0)
		{
			this.zoomOut();
		}
	}
	
	/**
	 * Handles layer show
	 */
	void _layerSwitchHandler (CustomEvent event)
	{
		this.switchToLayer(event.detail['id']);
        
		this._layers.forEach((Layer layer) =>
									layer.deselectAll());
		
		this._triggerUpdate();
	}
	
	/**
	 * Handles stuff update
	 */
	void _layerUpdateHandler (CustomEvent event)
	{
		this._triggerUpdate();
	}
	
	/**
	 * Handles tool change
	 */
	void _toolChangeHandler (CustomEvent event)
	{
		// Clear selection if any other tool being selected
		if (event.detail['id'] != Tool.SELECT)
		{
			this.globalDeselection();
		}
	}
	
	/**
	 * Checks panning
	 */
	void _proceedPanning (Point base)
	{
		// Calculate new point
		Point newPoint = base - this._panStartedAt + this._panStartedOffset;
		
		// Block then viewport is out of top left edge range
		if (newPoint.x > MAX_OFFSET_LIMIT ||
			newPoint.y > MAX_OFFSET_LIMIT)
		{
			newPoint = new Point(newPoint.x > MAX_OFFSET_LIMIT ? MAX_OFFSET_LIMIT : newPoint.x,
								 newPoint.y > MAX_OFFSET_LIMIT ? MAX_OFFSET_LIMIT : newPoint.y);
		}
		
		// Block then viewport is out of top right edge range
		int widthLimit = -(this._base.width - window.innerWidth + MAX_OFFSET_LIMIT),
			heightLimit = -(this._base.height - window.innerHeight + MAX_OFFSET_LIMIT);
		
		if (newPoint.x < widthLimit ||
			newPoint.y < heightLimit)
		{
			newPoint = new Point(newPoint.x < widthLimit ? widthLimit : newPoint.x,
								 newPoint.y < heightLimit ? heightLimit : newPoint.y);
		}
		
		// Dispatch PAN_MOVE event with fixed position
		window.dispatchEvent(new CustomEvent(Editor.PAN_MOVE_EVENT, detail: { 'position': newPoint }));
		
		// Focus on new point
		this._moveTo(newPoint);
	}
	
	/**
	 * Triggers project update
	 */
	void _triggerUpdate ( )
	{
		if (this._layers.isEmpty)
		{
			return;
		}
		
		window.dispatchEvent(new CustomEvent(UPDATE_EVENT, detail: { 'data': this.toMap() }));
	}
	
	/**
	 * Resizes canvas
	 */
	void _setSize ({ int width, int height })
	{
		// If no changes
		if (width	== null &&
			height	== null)
		{
			return;
		}
		
		// Calculate new values
		int newWidth	= (width == null)	? this.width	: width,
			newHeight	= (height == null)	? this.height	: height;
		
		// Resize layers
		for (Layer layer in this._layers)
		{
			layer.setSize(width: newWidth, height: newHeight);
		}
		
		// Resize editor
		this.width = newWidth;
		this.height = newHeight;
	}
	
	// Set transform
	void _setTransform ({ int x, int y, int z })
	{
		// If no changes
		if (x	== null &&
			x	== null &&
			z	== null)
		{
			return;
		}
	
		// Calculate new values
		int newX = (x == null) ? this.transform['x'] : x,
			newY = (y == null) ? this.transform['y'] : y,
			newZ = (z == null) ? this.transform['z'] : z;
		
		// Apply styles
		this._contentContainer.style.transform = 'translate3d(${newX}px, ${newY}px, ${newZ}px)';
	}
	
	// Fit to viewport
	void _fitTo (Rectangle base)
	{
		int x = (base.width - window.innerWidth) ~/ -2,
			y = (base.height - window.innerHeight) ~/ -2;
		
		this._setSize(width: base.width, height: base.height);
		this._setTransform(x: x, y: y, z: 0);
		
		// Timer prevents event not being handled on first call
		new Timer(new Duration(milliseconds: 1), ()
			{
				window.dispatchEvent(new CustomEvent(Editor.PAN_MOVE_EVENT, detail: { 'position': new Point(x, y) }));
			}
		);
	}
	
	// Jump to new origin
	void _moveTo (Point<int> point)
	{
		this._setTransform(x: point.x, y: point.y);
	}
	
	/**
	 * Zoom canvas absolutely
	 */
	void _zoomTo (double value)
	{
		// Check max limit
		if (value >= Editor.ZOOM_MAX)
		{
			// Dispatch ZOOM_MAX_ACHIEVED
			window.dispatchEvent(new CustomEvent(Editor.ZOOM_MAX_ACHIEVED_EVENT));
		}
		
		// Check min limit
		else if (value <= Editor.ZOOM_MIN)
		{
			// Dispatch ZOOM_MIN_ACHIEVED
			window.dispatchEvent(new CustomEvent(Editor.ZOOM_MAX_ACHIEVED_EVENT));
		}
		
		// Then no limit achieved so far
		else
		{
			this._scaleLevel = value;
			
			// Dispatch ZOOM_EVENT
			window.dispatchEvent(new CustomEvent(Editor.ZOOM_EVENT, detail: { 'level': this._scaleLevel }));
		}
	}
	
	/**
	 * Zoom canvas relative to active level
	 */
	void _zoom (double addendum)
	{
		this._zoomTo(this._scaleLevel + addendum);
	}
	
	/**
	 * Prevent layer widget from breaking apart
	 */
	void _synchronizeLayerWithWidget (String layerId)
 	{
		window.dispatchEvent(new CustomEvent(Layer.SWITCH_EVENT, detail: { 'id': layerId }));
	}
	
	/**
	 * Converts project object to portable map object
	 */
	Map<String, Object> toMap ( )
	{
		Map<String, Object> data = new Map<String, Object>();
		
		// Collect meta
		data['name'] = this._name;
		//data['updated'] = this._updated.toString();
		data['size'] = { 'width': this.width, 'length': this.height };
		data['activeLayerId'] = this.activeLayerId;
		
		// Collect layers data
		List<Map<String, Object>> layerData = new List<Map<String, Object>>();
		
		this.layers
		.forEach((Layer layer) =>
						layerData.add(layer.toMap()));
		
		data['layers'] = layerData;
		
		// Return map object
		return data;
	}
	
	/**
	 * Converts project object to json string
	 */
	@override String toString ( )
	{
		return JSON.encode(this.toMap());
	}
	
	/**
	 * Zoom canvas in by `Editor.ZOOM_STEP` value
	 */
	void zoomIn ( )
	{
		this._zoom(Editor.ZOOM_STEP);
		
		// Dispatch ZOOM_IN_EVENT
		window.dispatchEvent(new CustomEvent(Editor.ZOOM_IN_EVENT));
	}
	
	/**
	 * Zoom canvas out by `Editor.ZOOM_STEP` value
	 */
	void zoomOut ( )
	{
		this._zoom(-Editor.ZOOM_STEP);
		
		// Dispatch ZOOM_OUT_EVENT
		window.dispatchEvent(new CustomEvent(Editor.ZOOM_OUT_EVENT));
	}
	
	/**
	 * Reset canvas zoom
	 */
	void zoomReset ( )
	{
		this._zoomTo(1.0);
	}
	
	/**
	 * Undo last action
	 */
	void undo ( ) => this.activeLayer.rollback(-1);
	
	/**
	 * Redo last action
	 */
	void redo ( ) => this.activeLayer.rollback(1);
	
	/**
	 * Toggle avaible manipulaton features
	 */
	void toggleFeature ({ bool pan, bool zoom, bool resize })
	{
		// If no changes
		if (pan		== null &&
			zoom	== null &&
			resize	== null)
		{
			return;
		}
	
		// If pan flag passed
		if (pan != null)
		{
			this._isPanEnabled = pan;
		}
		
		// If zoom flag passed
		if (zoom != null)
		{
			this._isZoomEnabled = zoom;
		}
		
		// If resize flag passed
		if (resize != null)
		{
			this._isResizeEnabled = resize;
		}
	}
	
	/**
	 * Register new layer object
	 */
	void register (Layer layer)
	{
		this._layers.add(layer);
		this._layerContainer.children.add(layer.node);
		
		this.switchToLayer(layer.id);
		
		this._triggerUpdate();
	}
	
	/**
	 * Unregister layer object by its id
	 */
	void unregister (String layerId)
	{
		for (Layer layer in this._layers)
		{
			if (layer.id == layerId)
			{
				this._layers.remove(layer);
				
				layer.remove();
				
				break;
			}
		}
		
		this._triggerUpdate();
	}
	
	/**
	 * Clears project content
	 */
	void clear ( )
	{
		this._layers
		.forEach((Layer layer) =>
						layer.remove());
	}
	
	/**
	 * Enables grid
	 */
	void enableGrid ( )
	{
		this.disableGrid();
		
		this._grid = new Grid();
        this._gridContainer.append(this._grid.node);
	}
	
	/**
	 * Disables grid
	 */
	void disableGrid ( )
	{
		if (this._grid != null)
		{
			this._grid.removeNode();
		}
		
		this._grid = null;
	}
	
	/**
	 * Enables preview if possible
	 */
	/*
	bool enablePreview ( )
	{
		try
		{
			this._preview = new Preview(this._base);
			this._previewContainer.append(this._preview.node);
			
			this._triggerUpdate();
			
			return true;
		}
		catch (e)
		{
			return false;
		}
	}
	
	/**
	 * Disabled preview
	 */
	void disablePreview ( )
	{
		this._preview.removeNode();
        this._preview = null;
	}
	*/
	
	/**
	 * Switch to layer using its id
	 */
	void switchToLayer (String layerId)
	{
		this._layers.forEach((Layer layer) =>
								   (layer.id == layerId) ? layer.show() : layer.hide());
	}
	
	/**
	 * Switch to first layer in list
	 */
	void switchToFirstLayer ( )
	{
		this.switchToLayer(this._layers.first.id);
	}
	
	/**
	 * Creates new layer
	 */
	String createNewLayer ([ String name ])
	{
		this._lastLayerIndex++;
		
		if  (name == null)
		{
			name = '${Layer.DEFAULT_NAME} ${this._lastLayerIndex}';
		}
		
		Layer newLayer = new Layer(name);
		
		this.register(newLayer);
		
		return newLayer.id;
	}
	
	/**
	 * Creates duplicate of active layer
	 */
	void duplicateActiveLayer ( )
	{
		this._lastLayerIndex++;
		
		Map<String, Object> data = this.activeLayer.toMap();
		
		data.remove('id');
		
		Layer layer = new Layer.fromMap(data);
		
		layer.name += ' (1)';
		
		this.register(layer);
	}
	
	/**
	 * Removes active layer
	 */
	void removeActiveLayer ( )
	{
		if (this._layers.length <= 1)
		{
			return;
		}
		
		this.unregister(this.activeLayer.id);
		
		this.switchToFirstLayer();
	}
	
	/*
	 * Selects everything
	 */
	void globalSelection ( )
	{
		if (Tool.active != Tool.SELECT)
		{
			return;
		}
		
		this.activeLayer.selectAll();
	}
	
	/**
	 * Deselects everything
	 */
	void globalDeselection ( )
	{
		this._layers.forEach((Layer layer) =>
									layer.deselectAll());
	}
	
	/**
	 * Toggles everything
	 */
	void globalSelectionToggle ( )
	{
		if (Tool.active != Tool.SELECT)
		{
			return;
		}
		
		this.activeLayer.toggleSelectionAll();
	}
}