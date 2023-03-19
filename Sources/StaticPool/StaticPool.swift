/// A fixed size pool of objects with no dynamic memory allocation.
/// Provides validated access to its elements through opaque handles.
public struct StaticPool<T>
{
    /// Creates a new StaticPool with the given size
    public init(withSize size: Int)
    {
        assert(UInt32(size) <= 2^24) // We need 8 bits per slot for the allocation counter
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
            if self.slots[i].item == nil && self.slots[i].allocationCounter < UInt8.max
            {
                self.slots[i].item = item
                return Handle(slotIdx: i, id: self.slots[i].allocationCounter)
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
    ///     StaticPoolError.DanglingHandle: if the handle doesn't match the current allocation
    ///     counter of that slot
    public func get(_ handle: Handle) throws -> T
    {
        let (idx, id) = handle.decode()
        if idx >= self.slots.count
        {
            throw StaticPoolError.AccessOutOfBounds
        }

        if id != self.slots[idx].allocationCounter
        {
            throw StaticPoolError.DanglingHandle
        }

        if let item = self.slots[idx].item
        {
            return item
        }

        throw StaticPoolError.InvalidHandle
    }

    /// Releases the slot pointed by the provided handle if it's still valid.
    /// - Parameters:
    ///     - handle:
    /// - Throws: StaticPoolError.DanglingHandle: if the handle doesn't match the current allocation
    ///     counter of that slot.
    mutating public func release(handle: Handle) throws
    {
        let (idx, id) = handle.decode()
        if idx >= self.slots.count
        {
            return
        }

        if id != self.slots[idx].allocationCounter
        {
            throw StaticPoolError.DanglingHandle
        }

        self.slots[idx].item = nil
        self.slots[idx].allocationCounter += 1
    }

    /// Releases the slot at the provided index with no checks at all.
    /// - Parameters:
    ///     - index:
    mutating public func release(index: Int)
    {
        if index >= self.slots.count
        {
            return
        }
        self.slots[index].item = nil
        self.slots[index].allocationCounter += 1
    }

    /// Returns the number of slots that can still be reused. If this gets to 0, you might want to
    /// consider resetting some slots.
    /// - Returns: The number of slots that can still be reused
    public func getReusableSlotCount() -> Int
    {
        var count = 0
        for slot in self.slots
        {
            if slot.allocationCounter < UInt8.max
            {
                count += 1
            }
        }
        return count
    }

    /// Releases all slots and resets their allocation counters. This means that any dangling
    /// handles pointing to this slot might act as if they were still valid, so this must be used
    /// with care.
    mutating public func reset()
    {
        for i in 0..<self.slots.count
        {
            self.reset(slot: i)
        }
    }

    /// Releases the slot and resets its allocation counter. This means that any dangling handles
    /// pointing to this slot might act as if they were still valid, so this must be used with care.
    /// - Parameters:
    ///     - index:
    mutating public func reset(slot index: Int)
    {
        if index >= self.slots.count
        {
            return
        }
        self.slots[index].item = nil
        self.slots[index].allocationCounter = 0
    }

    /// An opaque pointer to a slot in the pool. Can't be used on pools of different types.
    public struct Handle
    {
        fileprivate init(slotIdx: Int, id: UInt8)
        {
            assert(slotIdx <= 2^24)

            data = (UInt32(slotIdx) << 8) + UInt32(id)
        }

        fileprivate func decode() -> (idx: Int, id: UInt8)
        {
            (Int(self.data >> 8 ), UInt8(self.data & 0xffffff00))
        }

        private let data: UInt32
    }

    // MARK: - Private
    private var slots: [Slot<T>]

    private struct Slot<T>
    {
        var item: T? = nil
        var allocationCounter: UInt8 = 0
    }
}

public enum StaticPoolError : Error
{
    case AccessOutOfBounds
    case NoAvailableSlots
    case InvalidHandle
    case DanglingHandle
}
