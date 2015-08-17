part of planner;

/*
 *	Key class.
 *
 *	Stores list of keyboard keys as static field.
 *	Custom keys could be create with "new Key(...)".
 *	Only default keys avaible as constants.
 */
class Key
{
	// Constants
	static const ESC = 27, BACKSPACE = 8, TAB = 9, BACKSLASH = 220,
				 HOME = 36, PAGEUP = 33, PAGEDOWN = 34, BREAK = 19,
				 CAPSLOCK = 20, ENTER = 13, DELETE = 46, END = 36,
				 SHIFT = 16, CTRL = 17, ALT = 18, SPACE = 32, MENU = 93,
				 UP = 38, LEFT = 37, RIGHT = 39, DOWN = 40,
				 A = 65, B = 66, C = 67, D = 68, E = 69, F = 70, G = 71, H = 72, I = 73, J = 74,
				 K = 75, L = 76, M = 77, N = 78, O = 79, P = 80, Q = 81, R = 82, S = 83, T = 84,
				 U = 85, V = 86, W = 87, X = 88, Y = 89, Z = 90,
				 ZERO = 48, /* TODO: 1, 2, 3... */ NINE = 57,
				 MINUS = 189, PLUS = 187;

	// Default keyboard keys
	static List<Key> _defaults = [
		new Key(BACKSPACE,	'Backspace',		'&#x232B;'),
		new Key(TAB,		'Tab',				'&#x21E5;'),
		new Key(ENTER,		'Enter',			'&#x21A9;'),
		new Key(SHIFT,		'Shift',			'&#x21E7;'),
		new Key(CTRL,		'Control',			'Ctrl'),
		new Key(ALT,		'Alt'),
		new Key(BREAK,		'Pause / Break',	'Break'),
		new Key(CAPSLOCK,	'Caps Lock',		'CpsLck'),
		new Key(ESC,		'Escape',			'Esc'),
		new Key(SPACE,		'Space',			'_'),
		new Key(PAGEUP,		'Page Up',			'PgUp'),
		new Key(PAGEDOWN,	'Page Down',		'GpDn'),
		new Key(END,		'End'),
		new Key(HOME,		'Home'),
		new Key(LEFT,		'Left Arrow',		'&larr;'),
		new Key(UP,			'Up Arrow',			'&uarr;'),
		new Key(RIGHT,		'Right Arrow',		'&rarr;'),
		new Key(DOWN,		'Down Arrow',		'&darr;'),
		new Key(DELETE,		'Delete',			'Del'),
		new Key(A, 'A'),
		new Key(B, 'B'),
		new Key(C, 'C'),
		new Key(D, 'D'),
		new Key(E, 'E'),
		new Key(F, 'F'),
		new Key(G, 'G'),
		new Key(H, 'H'),
		new Key(I, 'I'),
		new Key(J, 'J'),
		new Key(K, 'K'),
		new Key(L, 'L'),
		new Key(M, 'M'),
		new Key(N, 'N'),
		new Key(O, 'O'),
		new Key(P, 'P'),
		new Key(Q, 'Q'),
		new Key(R, 'R'),
		new Key(S, 'S'),
		new Key(T, 'T'),
		new Key(U, 'U'),
		new Key(V, 'V'),
		new Key(W, 'W'),
		new Key(X, 'X'),
		new Key(Y, 'Y'),
		new Key(Z, 'Z'),
		new Key(MENU,		'Menu'),
		new Key(BACKSLASH,	'Backslash',		'\\'),
		new Key(ZERO,		'Zero',				'0'),
		new Key(MINUS,		'Minus',			'[-]'),
		new Key(PLUS,		'Plus',				'[+]')
	];
	
	// Data
	final int		code;
	final String	name;
	final String	_shortcut;
	
	// Constructor
	Key (this.code, this.name, [ this._shortcut ]);
	
	// Getters
	String get shortcut => (this._shortcut == null) ? this.name : this._shortcut;
	
	// Get key by code
	static Key get (int code)
	{
		for (Key key in Key._defaults)
		{
			if (key.code == code)
			{
				return key;
			}
		}
		
		return null;
	}
	
	// Get readable shortcut of key group
	static String toReadable (List<int> keys)
	{
		List<String> result = new List<String>();
		
		for (int code in keys)
		{
			result.add(Key.get(code).shortcut);
		}
		
		return result.join('+');
	}
}

/*
 *	Hotkey manager class.
 *
 *	This class listen to global key* events
 *	and stores pressed keys in static field.
 *	Triggers custom KEY_COMBINATION event on
 *	window object then any key pressed.
 */
class Hotkey
{
	/*
	 * Defaults
	 */
	static const COMBINATION_EVENT	= 'onKeyCombination';

	/*
	 * Data
	 */
	static Set<int>		active = new Set<int>();
	static bool			enabled = true;
	Map<String, StreamSubscription> _listeners = new Map<String, StreamSubscription>();
	
	/*
	 * Constructor
	 */
	Hotkey ( )
	{
		this._listeners['onKeyDown']	= window.on['keydown'].listen(this._keyDownHandler);
		this._listeners['onKeyUp']		= window.on['keyup'].listen(this._keyUpHandler);
	}
	
	/**
	 * Handles key down
	 */
	void _keyDownHandler (KeyboardEvent event)
	{
		if (Hotkey.enabled == false)
		{
			return;
		}
		
		KeyEvent keyEvent = new KeyEvent.wrap(event);
		
		Hotkey.active.add(keyEvent.keyCode);
		
		window.dispatchEvent(new CustomEvent(COMBINATION_EVENT, detail: { 'originalEvent': event }));
	}
	
	/**
	 * Handles key up
	 */
	void _keyUpHandler (KeyboardEvent event)
	{
		KeyEvent keyEvent = new KeyEvent.wrap(event);
		
		Hotkey.active.remove(keyEvent.keyCode);
	}
}