part of planner;

/**
 *	Editor class
 *	
 *	Allows to manage project
 */
class Editor extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const ID							= 'editor',
				 DEFAULT_NAME				= 'Untitled project',
				 OFFLINE_PROJECT_KEY		= 'lastProjectData',
				 
				 // Events
				 PAN_START_EVENT			= 'onPanStart',
				 PAN_MOVE_EVENT				= 'onPanMove',
				 PAN_END_EVENT				= 'onPanEnd',
				 ZOOM_EVENT					= 'onZoom',
				 ZOOM_IN_EVENT				= 'onZoomIn',
				 ZOOM_OUT_EVENT				= 'onZoomOut',
				 ZOOM_MAX_ACHIEVED_EVENT	= 'onZoomMax',
				 ZOOM_MIN_ACHIEVED_EVENT	= 'onZoomMin',
				 
				 // Zoom setup
				 ZOOM_STEP					= 0.1,
				 ZOOM_MAX					= 1.5,
				 ZOOM_MIN					= 0.5,
				 
				 // Connection setup
				 DEBUG_CONNECTION			= false,
				 DEFAULT_CONNECTION_HOST	= '127.0.0.1',
				 DEFAULT_CONNECTION_PORT	= 21333,
				 
				 // Canvas
				 PIXELS_PER_METER			= 60.0;

	/*
	 * Data
	 */
	static Point<num> offset = new Point<num>(0, 0);
	
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	Element							_node;
	Project							_project;
	WebSocket						_connection;
	bool							_reconnectScheduled				= true;
	int								_reconnectDelay					= 1000;
	
	/*
	 * Constructor
	 */
	Editor ( )
	{
		// Create node
		this._node = new Element.html('<section id="$ID"></section>');
		
		this._compose();
		
		// Connect to socket
		this.connectToServer();
		
		// Event listeners
		this._listeners['onToolChange']		= window.on[Tool.CHANGE_EVENT].listen(this._toolChangeHandler);
		this._listeners['onPanMove']		= window.on[PAN_MOVE_EVENT].listen(this._panMoveHandler); // TODO: Any better way to track panning?
		this._listeners['onProjectUpdate']	= window.on[Project.UPDATE_EVENT].listen(this._projectUpdateHandler);
		
		this.switchToTool(Tool.SELECT);
	}
	
	/*
	 * Getters
	 */
	static bool	get isOfflineProjectExsits => window.localStorage.containsKey(OFFLINE_PROJECT_KEY);
	bool		get isGridEnabled => this._project.isGridEnabled;
	//bool		get isPreviewEnabled => this._project.isPreviewEnabled;
	Element		get node => this._node;
	
	/**
	 * 
	 */
	void _toolChangeHandler (CustomEvent event)
	{
		// Set tool as active
		Tool.active = event.detail['id'];
		
		// Show context section
		window.dispatchEvent(new CustomEvent(ContextMenuSection.CLOSE_EVENT, detail: { 'ids': [ 'Select',
		                                                                                        'Wall',
		                                                                                        'Floor' ] }));
		
		ContextMenuSection section;
		
		// Open selection tab
		if (Tool.active == Tool.SELECT)
		{
			section = new ContextMenuSection('Select', [
				new MenuSectionGroup('Scripts', [
					//new MenuSectionGroupLabelItem('Select Visible',				Action.alias('selectVisible')),
	    			new MenuSectionGroupLabelItem('Select All',					Action.alias('selectAll')),
	    			new MenuSectionGroupLabelItem('Clear Selection',			Action.alias('selectNone')),
	    			new MenuSectionGroupLabelItem('Toggle Selection',			Action.alias('selectToggle'))
	    		])
    		]);
			
			window.dispatchEvent(new CustomEvent(ContextMenuSection.CREATE_EVENT, detail: { 'section': section }));
		}
		/*
		else if (Tool.active == Tool.WALL)
		{
			section = new ContextMenuSection('Wall', [
				
    		]);
		}
		else if (Tool.active == Tool.FLOOR)
		{
			section = new ContextMenuSection('Floor', [
				
    		]);
		}
		else
		{
			throw new Exception('?');
		}
		*/
	}
	
	/**
	 * Handles pan move
	 */
	void _panMoveHandler (CustomEvent event)
	{
		Editor.offset = event.detail['position'];
	}
	
	/**
	 * Handles project changes
	 */
	void _projectUpdateHandler (CustomEvent event)
	{
		this.saveActiveProjectOffline();
	}
	
	/**
	 * Handles socket connection
	 */
	void _connectionOpenHandler (Object object)
	{
		if (DEBUG_CONNECTION)
		{
			print('Connected to socket at $DEFAULT_CONNECTION_HOST:$DEFAULT_CONNECTION_PORT');
		}
	}
	
	/**
	 * Handles incoming socket messages
	 */
	void _connectionMessageHandler (MessageEvent object)
	{
		if (DEBUG_CONNECTION)
		{
			print('Socket message: ${object.data}');
		}
	}
	
	/**
	 * Handles socket close
	 */
	void _connectionCloseHandler (CloseEvent event)
	{
		if (DEBUG_CONNECTION)
		{
			print('Socket closed: ${event.reason}');
		}
		
		this._scheduleReconnect();
	}
	
	/**
	 * Handles socket error
	 */
	void _connectionErrorHandler (Event event)
	{
		if (DEBUG_CONNECTION)
		{
			print('Socket error: ${event}');
		}
		
		this._scheduleReconnect();
	}
	
	/**
	 * Sets timer to reconnect to server later
	 */
	void _scheduleReconnect ( )
	{
		new Timer(new Duration(seconds: this._reconnectDelay), this.connectToServer);
	}
	
	/*
	 * Aliases
	 */
	Map<String, Object> toMap ( ) => this._project.toMap();
	
	void zoomIn		( ) => this._project.zoomIn();
	void zoomOut	( ) => this._project.zoomOut();
	void zoomReset	( ) => this._project.zoomReset();
	
	void undo		( ) => this._project.undo();
	void redo		( ) => this._project.redo();
	
	void selectVisible ( )
	{
		Layer active = this._project.activeLayer;
		
		active.selectAll(active.queryObjectsInArea(new Rectangle(Editor.offset.x, Editor.offset.y, window.innerWidth, window.innerHeight)));
	}
	
	void selectAll	( ) => this._project.globalSelection();
	void deselectAll ( ) => this._project.globalDeselection();
	void toggleAll ( ) => this._project.globalSelectionToggle();
	void removeSelection ( ) => this._project.activeLayer.removeSelection();
	
	String createNewLayer	( ) => this._project.createNewLayer();
	void duplicateActiveLayer ( ) => this._project.duplicateActiveLayer();
	void removeActiveLayer	( ) => this._project.removeActiveLayer();
	
	void enableGrid ( ) => this._project.enableGrid();
    void disableGrid ( ) => this._project.disableGrid();
	/*bool enablePreview ( ) => this._project.enablePreview();
	void disablePreview ( ) => this._project.disablePreview();*/
    
	void switchToTool (String toolId)
	{
		window.dispatchEvent(new CustomEvent(Tool.CHANGE_EVENT, detail: { 'id': toolId }));
	}
	
	void reverseSelectedWalls ( )
	{
		this._project.activeLayer.walls.where((Wall wall) => wall.isSelected)
									   .forEach((Wall wall) =>
													  wall.reverse());
	}
	
	/**
	 * Creates socket connection
	 */
	void connectToServer ( )
	{
		this._connection = new WebSocket('ws://$DEFAULT_CONNECTION_HOST:$DEFAULT_CONNECTION_PORT')
		..on['open'].listen(this._connectionOpenHandler)
		..on['message'].listen(this._connectionMessageHandler)
		..on['error'].listen(this._connectionErrorHandler)
		..on['close'].listen(this._connectionCloseHandler);
	}
	
	/**
	 * Creates new project
	 */
	void createNewProject ( )
	{
		this.closeActiveProject();
		
		PromptDialog dialog = new PromptDialog('New project', 'Type new project name');
		
		dialog.on[Modal.DONE_EVENT].listen((CustomEvent event)
			{
				this._project = new Project(new Rectangle(Project.DEFAULT_WIDTH ~/ 2,
														  Project.DEFAULT_LENGTH ~/ 2,
														  Project.DEFAULT_WIDTH,
														  Project.DEFAULT_LENGTH),
	    												  (event.detail['inputs'][0] as InputElement).value);
	            		
	            this._node.children.add(this._project.node);
			}
		);
	}
	
	/**
	 * Loads existed project form server
	 */
	void openExistedProject (String jsonData)
	{
		this.closeActiveProject();
		
		this._project = new Project.fromMap(jsonData);
		
		this._node.children.add(this._project.node);
	}
	
	/**
	 * Saves project offline only
	 */
	void saveActiveProjectOffline ( )
	{
		// Check for active project
		if (this._project == null)
		{
			return;
		}
		
		// Collect data
		String data = this._project.toString();
		print(data);
		// Save data offline
		window.localStorage[OFFLINE_PROJECT_KEY] = data;
	}
	
	/**
	 * Saves project online only
	 */
	bool saveActiveProjectOnline ( )
	{
		// Check for active project
		if (this._project == null)
		{
			return false;
		}
		
		// Collect data
		DateTime lastModified = new DateTime.now();
		String data = this._project.toString();
		
		// If no editor server connection
		if (this._connection == null ||
			this._connection.readyState != WebSocket.OPEN)
		{
			return false;
		}
		
		// Send data through web socket to server
		this._connection.sendString(data);
		
		return true;
	}
	
	/**
	 * Save project both offline and online
	 */
	void saveActiveProject ( )
	{
		this.saveActiveProjectOffline();
		this.saveActiveProjectOnline();
	}
	
	/**
	 * Clears offline project data
	 */
	void clearOfflineProject ( )
	{
		window.localStorage.remove(OFFLINE_PROJECT_KEY);
	}
	
	/**
	 * Closes active project
	 */
	void closeActiveProject ( )
	{
		if (this._project == null)
		{
			return;
		}
		
		//this.saveActiveProject(); // Saves project online only
		this.clearOfflineProject();
		
		this._project.clear();
		this._project.removeNode();
		this._project = null;
	}
}