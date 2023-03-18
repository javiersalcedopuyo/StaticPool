# StaticPool

A fixed size pool of objects with no dynamic memory allocation.
Provides validated access to its elements through opaque handles.

---

### `init(withSize size: Int)`
Creates a new pool with the given size
- *Parameters*:
    - size:

---

### `add(_ item: T) throws -> Handle`
Inserts a new item in the first available slot.
- *Parameters*:
    - item:
- *Returns*: An optional handler that points to the slot where the item has been inserted
- *Throws*:
    - `StaticPoolError.NoAvailableSlots`: if the pool is full

---

### `get(_ handle: Handle) throws -> T`
Gets the item in the slot pointed by the provided handle
- *Parameters*:
    - handle:
- *Returns*: The item in the corresponding slot
- *Throws*:
    - `StaticPoolError.AccessOutOfBounds`: if the handle points outside the pool
    - `StaticPoolError.InvalidHandle`: If the handle points to an empty slot

---

###  `release(handle: Handle)`
Releases the slot pointed by the provided handle.
- *Parameters*:
    - handle:

---

### `release(index: Int)`
Releases the slot at the provided index.
- *Parameters*:
    - handle: