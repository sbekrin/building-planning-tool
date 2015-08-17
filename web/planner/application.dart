part of planner;

// TODO: Move somewhere
Point<double> PointIntToDouble (Point<int> object)
{
	return new Point(object.x.toDouble(), object.y.toDouble());
}

Point<int> PointDoubleToInt (Point<double> object)
{
	return new Point(object.x.toInt(), object.y.toInt());
}

/**
 * Application class.
 * Main class which controls almost everything.
 */
class Application extends InterfaceItem implements IContextBubbleProvider
{
	/*
	 * Defualts
	 */
	static const ID					= 'application-view',
				 FULLSCREEN_CLASS	= 'fullscreen';
	
	/*
	 * Data
	 */
	Editor							_editor;
	Menu							_menu;
	Hotkey							_hotkey				= new Hotkey();
	Interface						_interface			= new Interface();
	//Localization					_localization		= new Localization();
	Settings						_settings			= new Settings();
	List<InterfaceBlock>			_blocks				= new List<InterfaceBlock>();
	Map<String, StreamSubscription>	_listeners			= new Map<String, StreamSubscription>();
	
	/*
	 * Constructor
	 */
	Application ( )
	{
		// Create node
		this._node = new Element.html('<div id="$ID"></div>');
		
		// Event listeners
		this._listeners['onDragOver']	= window.on['dragover'].listen(this._dragOverHandler);
		this._listeners['onZoomMax']	= window.on[Editor.ZOOM_MAX_ACHIEVED_EVENT].listen(this._zoomMaxAchievedHandler);
		this._listeners['onZoomMin']	= window.on[Editor.ZOOM_MIN_ACHIEVED_EVENT].listen(this._zoomMinAchievedHandler);
		
		// Actions
		new Action('projectNew',	() => this._editor.createNewProject());
		new Action('projectOpen',	() => this._editor.openExistedProject(null), [ Key.CTRL, Key.SHIFT, Key.O ]); // TODO
		new Action('projectSave',	() => this._editor.saveActiveProject(), [ Key.CTRL, Key.S ]);
		new Action('projectClose',	() => this._editor.closeActiveProject());
		
		new Action('editUndo',		() => this._editor.undo(), [ Key.CTRL, Key.Z ]);
		new Action('editRedo',		() => this._editor.redo(), [ Key.CTRL, Key.Y ]);
		new Action('editRemove',	() => this._editor.removeSelection(), [ Key.DELETE ]);
		
		new Action('toolSelect',	() => this._editor.switchToTool(Tool.SELECT));
		new Action('toolWall',		() => this._editor.switchToTool(Tool.WALL));
		new Action('toolFloor',		() => this._editor.switchToTool(Tool.FLOOR));
		
		new Action('selectVisible',	() => this._editor.selectVisible());
		new Action('selectAll',		() => this._editor.selectAll(), [ Key.CTRL, Key.A ]);
		new Action('selectNone',	() => this._editor.deselectAll());
		new Action('selectToggle',	() => this._editor.toggleAll());
		
		new Action('layerCreate',		() => this._editor.createNewLayer());
		new Action('layerDuplicate',	() => this._editor.duplicateActiveLayer());
		new Action('layerRemove',		() => this._editor.removeActiveLayer());
		
		new Action('viewZoomIn',		() => this._editor.zoomIn(), [ Key.CTRL, Key.PLUS ]);
		new Action('viewZoomOut',		() => this._editor.zoomOut(), [ Key.CTRL, Key.MINUS ]);
		new Action('viewZoomReset',		() => this._editor.zoomReset(), [ Key.CTRL, Key.ZERO ]);
		new Action('viewToggleAnchorSnap',	() => Settings.toggle('anchor-snap'));
		new Action('viewToggleWallSnap',	() => Settings.toggle('wall-snap'));
		new Action('viewToggleGridSnap',	() => Settings.toggle('grid-snap'));
		new Action('viewToggleGrid',		() => this._toggleGrid());
		//new Action('viewTogglePreview',		() => this._togglePreview());
		new Action('viewToggleFullscreen',	() => this._toggleFullscreen());
		
		new Action('wallReverse',			() => this._editor.reverseSelectedWalls());
		
		// Menu setup
		this._menu = new Menu([
			new MenuShortcut(new Icon('save'),	Action.alias('projectSave')),
			new MenuShortcut(new Icon('undo'),	Action.alias('editUndo')),
			new MenuShortcut(new Icon('redo'),	Action.alias('editRedo')),
			new MenuSection('Project', [
				new MenuSectionGroup('Project History', [
	    			new MenuSectionGroupLabelItem('Undo',					Action.alias('editUndo'), 		icon: new Icon('undo'),	vertical: true),
	    			new MenuSectionGroupLabelItem('Redo',					Action.alias('editRedo'), 		icon: new Icon('redo'),	vertical: true)
	    		]),
	    		new MenuSectionGroup('Project Manager', [
					new MenuSectionGroupLabelItem('New Project&hellip;',	Action.alias('projectNew'),		icon: new Icon('new')),
					//new MenuSectionGroupLabelItem('Open Project List',			Action.alias('projectList'),	icon: new Icon('folder'))
				]),
				new MenuSectionGroup('Active Project', [
					new MenuSectionGroupLabelItem('Save Project',			Action.alias('projectSave'),	icon: new Icon('save'))
				])
			]),
			new MenuSection('Structure', [
				new MenuSectionGroup('Selection', [
					new MenuSectionGroupLabelItem('Select',					Action.alias('toolSelect'),		icon: new Icon('cursor'), vertical: true),
				]),
              	new MenuSectionGroup('Base', [
					new MenuSectionGroupLabelItem('Draw Wall',				Action.alias('toolWall'),		icon: new Icon('wall')),
					new MenuSectionGroupLabelItem('Draw Floor',				Action.alias('toolFloor'),		icon: new Icon('floor'))
	    		])
    		]),
    		new MenuSection('Furniture', [
  				new MenuSectionGroup('Selection', [
  					new MenuSectionGroupLabelItem('Select',					Action.alias('toolSelect'),		icon: new Icon('cursor'), vertical: true),
  				]),
				new MenuSectionGroup('Embeddable', [
    				new MenuSectionGroupList([
						new MenuSectionGroupLabelItem('Arch',		Action.alias(null),	data: { 'type': CanvasObject.CLASS, 'class': Door.CLASS }),
						new MenuSectionGroupLabelItem('Door',		Action.alias(null),	data: { 'type': CanvasObject.CLASS, 'class': null }),
						new MenuSectionGroupLabelItem('Window',		Action.alias(null),	data: { 'type': CanvasObject.CLASS, 'class': null })						
    				], dragable: true)
    			])
    		]),
    		new MenuSection('View', [
 				new MenuSectionGroup('Selection', [
 					new MenuSectionGroupLabelItem('Select',					Action.alias('toolSelect'),		icon: new Icon('cursor'), vertical: true),
 				]),
				new MenuSectionGroup('Zooming', [
					new MenuSectionGroupLabelItem('Zoom In',				Action.alias('viewZoomIn'),		icon: new Icon('zoom-in')),
					new MenuSectionGroupLabelItem('Zoom Out',				Action.alias('viewZoomOut'),	icon: new Icon('zoom-out')),
					new MenuSectionGroupLabelItem('Reset Zoom',				Action.alias('viewZoomReset'),	icon: new Icon('zoom-reset'))
				]),
				new MenuSectionGroup('Snapping', [
					new MenuSectionGroupToggleableItem('Snap to Anchors',	Action.alias('viewToggleAnchorSnap'),	checked: true),
					new MenuSectionGroupToggleableItem('Snap to Walls',		Action.alias('viewToggleWallSnap'),		checked: true),
					//new MenuSectionGroupToggleableItem('Snap to Grid',		Action.alias('viewToggleGridSnap'))
				]),
				new MenuSectionGroup('Visuals', [
					//new MenuSectionGroupToggleableItem('Show Preview',		Action.alias('viewTogglePreview'),		beta: true),
					new MenuSectionGroupToggleableItem('Show Grid',			Action.alias('viewToggleGrid'),			checked: true),
					new MenuSectionGroupLabelItem('Toggle Fullscreen',		Action.alias('viewToggleFullscreen'))
				])
			])
		]);
		
		this.register(this._menu);
		
		// Register tools widget
		/*
		ToolsWidget toolsWidget = new ToolsWidget();
		
		toolsWidget.registerAll
		([ 
			new Tool (Tool.SELECT,	'Selection Tool',	Key.V),
			new Tool (Tool.DRAW,	'Drawing Tool',		Key.BACKSLASH),
			new Tool (Tool.MOVE,	'Move Tool',		Key.M)
		]);
		
		this.register(toolsWidget);
		*/
		
		// Register layers widget
		LayersWidget layersWidget = new LayersWidget(Action.alias('layerCreate'),
													 Action.alias('layerDuplicate'),
													 Action.alias('layerRemove'));
		
		this.register(layersWidget);
		
		// TODO: Open demo project
		this._editor = new Editor();
		
		if (Editor.isOfflineProjectExsits)
		{
			this._editor.openExistedProject(window.localStorage[Editor.OFFLINE_PROJECT_KEY]);
		}
		else
		{
			this._editor.createNewProject();
		}
		
		this.register(this._editor);
		
		// Enable context bubble
		//this._bindContextBubbleEvents();
		
		// Append application node to top-level body
		document.body.children.add(this._node);
	}
	
	/*
	 * Getters
	 */
	bool			get isFullscreen		=> document.fullscreenElement != null;
	bool			get isNotFullscreen		=> !this.isFullscreen;
	List<Object>	get contextBubbleItems	=> [ new ContextBubbleOption('Project', Action.alias('toolsCollectData'), new Icon('check')), 
												 new ContextBubbleOption('Edit', Action.alias('toolsCollectData'), new Icon('check')),
												 new ContextBubbleOption('View', Action.alias('toolsCollectData'), new Icon('check')),
												 new ContextBubbleOption('Tools', Action.alias('toolsCollectData'), new Icon('check')) ];
	
	/**
	 * Handles drag over
	 * TODO: Block everything but *.json project files
	 */
	void _dragOverHandler (MouseEvent event)
	{
		event.preventDefault();
	}
	
	/**
	 * Handle max zooming
	 */
	void _zoomMaxAchievedHandler (CustomEvent event)
	{
		
	}
	
	/**
	 * Handle min zooming
	 */
	void _zoomMinAchievedHandler (CustomEvent event)
	{
		
	}
	
	/**
	 * Toggles grid
	 */
	void _toggleGrid ( )
	{
		if (this._editor.isGridEnabled)
		{
			this._editor.disableGrid();
		}
		else
		{
			this._editor.enableGrid();
		}
	}
	
	/**
	 * Toggles live preview
	 */
	/*
	void _togglePreview ( )
	{
		if (this._editor.isPreviewEnabled)
		{
			this._editor.disablePreview();
		}
		else
		{
			this._editor.enablePreview();
		}
	}
	*/
	
	/**
	 * Toggles fullscreen mode
	 */
	void _toggleFullscreen ( )
	{
		this._node.classes.toggle(FULLSCREEN_CLASS);
							
		if (this.isFullscreen)
		{
			document.exitFullscreen();
		}
		else
		{
			document.documentElement.requestFullscreen();
		}
	}
	
	/**
	 * Closes active project
	 */
	void _closeActiveProject ( )
	{
		this._editor.closeActiveProject();
	}
	
	/**
	 * Returns string with data in json format
	 */
	String collectData ( )
	{
		return JSON.encode(this._editor.toMap());
	}
	
	/**
	 * Register app object
	 */
	void register (Object object)
	{
		// Register interface block
		if (object is InterfaceBlock)
		{
			this._blocks.add(object);
			this._node.children.add(object.node);
			
			return;
		}
		
		// Then unexpected item passed
		throw new Exception('Attempt to register undefined object');
	}
	
	/**
	 * Register bunch of app objects
	 */
	void registerAll (List<Object> objectList)
	{
		for (Object object in objectList)
		{
			this.register(object);
		}
	}
}