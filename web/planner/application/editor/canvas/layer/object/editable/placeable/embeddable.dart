part of planner;

abstract class EmbeddableCanvasObject extends PlaceableCanvasObject
{
	/*
	 * Defaults
	 */
	static const String GHOST_CLASS = 'ghost';
	
	/*
	 * Data
	 */
	
	/*
	 * Getters
	 */
	bool get isGhost => this._node.classes.contains(GHOST_CLASS);
	
	/*
	 * Setters
	 */
	set isGhost (bool value) => (value == true) ? this._node.classes.add(GHOST_CLASS) : this._node.classes.remove(GHOST_CLASS);
}