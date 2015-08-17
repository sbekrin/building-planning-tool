part of planner;

/**
 * Removable interface for editor objects being possible
 * to remove.
 */
abstract class IRemovable
{
	void removeNode();
}

/**
 * Selectable interface for editor objects being possible
 * to select and manipulate.
 */
abstract class ISelectable
{
	void select();
	void deselect();
}

/**
 * Snapable interface for editor objects being possible
 * to snap to.
 */
abstract class ISnapable
{
	bool isSnapPoint(Point point);
	Point<double> getSnapPoint(Point<double> point);
}

/**
 * Rangeable interface editor objects being possible
 * to place in canvas and select via range selection
 */
abstract class IRangeable
{
	bool inRange(Rectangle area);
}

/**
 * Interface blocks which provides custom context bubble
 * to work with.
 */
abstract class IContextBubbleProvider
{
	List<Object> get contextBubbleItems;
}