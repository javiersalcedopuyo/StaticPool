# StaticPool
![Unit Testing](https://github.com/javiersalcedopuyo/StaticPool/workflows/Swift/badge.svg)

A fixed size pool of objects with no dynamic memory allocation.
Provides validated access to its elements through opaque handles.

Inspired by [this blog article](https://floooh.github.io/2018/06/17/handles-vs-pointers.html).

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
    - `StaticPoolError.DanglingHandle`: If the handle doesn't match the current allocation of that slot

---

### `getReusableSlotCount() -> Int`
Returns the number of slots that can still be reused. If this gets to 0, you might want to consider resetting some slots.
- *Returns*: The number of slots that can still be reused

---

###  `release(handle: Handle) throws`
Releases the slot pointed by the provided handle.
- *Parameters*:
    - handle:
- *Throws*:
    - `StaticPoolError.DanglingHandle`: If the handle doesn't match the current allocation of that slot

---

### `release(index: Int)`
Releases the slot at the provided index.
- *Parameters*:
    - index:

---

### `reset()`
Releases all slots and resets their allocation counters. This means that any dangling handles pointing to this slot might act as if they were still valid, so this must be used with care.

---

### `reset(slot: Int)`
Releases the slot at the provided index and resets its allocation counter. This means that any dangling handles pointing to this slot might act as if they were still valid, so this must be used with care.
- *Parameters*:
    - slot:
