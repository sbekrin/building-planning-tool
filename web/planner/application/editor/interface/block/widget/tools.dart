part of planner;

class ToolsWidget extends Widget
{
	// Defaults
	static const DEFAULT_TOOL = Tool.SELECT;
	
	// Data
	List<Tool>						_tools		= new List<Tool>();
	ButtonSwitcher					_switcher	= new ButtonSwitcher();
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	
	// Constructor
	ToolsWidget ( ): super('Tools', id: 'tools', horizal: Widget.SNAP_LEFT, vertical: Widget.SNAP_TOP)
	{
		this._content.children.add(this._switcher.node);
		
		// Event listeners
		this._listeners['onHotkey']			= window.on[Hotkey.COMBINATION_EVENT].listen(this._hotkeyHandler);
		this._listeners['onToolChange']		= window.on[Tool.CHANGE_EVENT].listen(this._toolChangeHandler);
	}
	
	/**
	 * TODO: Handles hotkey
	 */
	void _hotkeyHandler (CustomEvent event)
	{
		//this._tools.firstWhere((Tool tool) => Hotkey.active.contains(tool.hotkey), orElse: null).click();
	}
	
	// Handle tool change
	void _toolChangeHandler (CustomEvent event)
	{
		String toolId = event.detail['id'];
		
		Tool.active = toolId;
	}
	
	/*
	 *	Register single tool
	 */
	void register (Tool tool)
	{
		this._tools.add(tool);
		this._switcher.register(new ButtonSwitcherItem.fromButton(tool.button));
		
		// Activate tools if set default
		if (tool.id == DEFAULT_TOOL)
		{
			tool.setActive();
		}
	}
	
	/*
	 *	Register tool list
	 */
	void registerAll (List<Tool> tools)
	{
		for (Tool tool in tools)
		{
			this.register(tool);
		}
	}
}