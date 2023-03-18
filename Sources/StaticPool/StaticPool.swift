/// A fixed size pool of objects with no dynamic memory allocation.
/// Provides validated access to its elements through opaque handles.
public struct StaticPool<T>
{
    /// Creates a new StaticPool with the given size
    public init(withSize size: Int)
    {
        slots = Array(repeating: Slot<T>(), count: size)
    }

    /// Inserts a new item in the first available slot.
    /// - Parameters:
    ///     - item:
    /// - Returns: An optional handler that points to the slot where the item has been inserted
    /// - Throws: StaticPoolError.NoAvailableSlots if the pool is full
    mutating public func add(_ item: T) throws -> Handle
    {
        for i in self.slots.indices
        {
            if self.slots[i].item == nil
            {
                self.slots[i].item = item
                return Handle(data: UInt32(i))
            }
        }
        throw StaticPoolError.NoAvailableSlots
    }

    /// Gets the item in the slot pointed by the provided handle
    /// - Parameters:
    ///     - handle:
    /// - Returns: The item in the corresponding slot
    /// - Throws: StaticPoolError.AccessOutOfBounds: if the handle points outside the pool
    ///     StaticPoolError.InvalidHandle: If the handle points to an empty slot
    public func get(_ handle: Handle) throws -> T
    {
        if handle.data >= self.slots.count
        {
            throw StaticPoolError.AccessOutOfBounds
        }

        if let item = self.slots[Int(handle.data)].item
        {
            return item
        }

        throw StaticPoolError.InvalidHandle
    }

    /// Releases the slot pointed by the provided handle.
    /// - Parameters:
    ///     - handle:
    mutating public func release(handle: Handle)
    {
        let idx = Int(handle.data)
        if idx >= self.slots.count
        {
            return
        }

        self.slots[idx].item = nil
    }

    /// Releases the slot at the provided index.
    /// - Parameters:
    ///     - handle:
    mutating public func release(index: Int)
    {
        if index >= self.slots.count
        {
            return
        }
        self.slots[index].item = nil
    }

    /// An opaque pointer to a slot in the pool. Can't be used on pools of different types.
    public struct Handle { let data: UInt32 }

    // MARK: - Private
    private var slots: [Slot<T>]

    private struct Slot<T>
    {
        var item: T? = nil
        // TODO: var counter: UInt8 = 0
    }
}

public enum StaticPoolError : Error
{
    case AccessOutOfBounds
    case NoAvailableSlots
    case InvalidHandle
}
