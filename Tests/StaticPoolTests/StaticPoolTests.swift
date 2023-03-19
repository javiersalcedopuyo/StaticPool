import XCTest
@testable import StaticPool

final class StaticPoolTests: XCTestCase
{
    struct Foo { var id = 0 }

    var pool = StaticPool<Foo>(withSize: 1)

    func testAddElement()
    {
        XCTAssertNoThrow( try pool.add(Foo()) )
    }

    func testAddAndGetNotNil()
    {
        let handle = try! pool.add( Foo() )

        XCTAssertNoThrow( try pool.get(handle) )
    }

    func testAddToFullPool()
    {
        _ = try! pool.add( Foo() )
        XCTAssertThrowsError( try pool.add( Foo() ) )
    }

    func testReleaseByIndex()
    {
        let handle = try! pool.add( Foo() )

        pool.release(index: 0)
        XCTAssertThrowsError( try pool.get(handle) )
    }

    func testReleaseByHandle()
    {
        let handle = try! pool.add( Foo() )

        XCTAssertNoThrow( try pool.release(handle: handle) )
        XCTAssertThrowsError( try pool.get(handle) )
    }

    func testGettingDanglingHandle()
    {
        do
        {
            let handle = try pool.add( Foo(id: 0) )
            try! pool.release(handle: handle)
            _ = try pool.add( Foo(id: 1) )

            XCTAssertThrowsError(try pool.get(handle) )
        }
        catch
        {
            XCTFail()
        }
    }

    func testDoubleRelease()
    {
        do
        {
            let handle = try pool.add( Foo(id: 0) )
            try! pool.release(handle: handle)

            XCTAssertThrowsError(try pool.release(handle: handle) )
        }
        catch
        {
            XCTFail()
        }
    }

    func testResetSlotWithDanglingHandle()
    {
        let handle = try! pool.add( Foo(id: 0) )
        pool.reset(slot: 0)
        _ = try! pool.add( Foo(id: 1) )

        XCTAssertNoThrow(try pool.get(handle) )
    }

    func testExhaustingPool()
    {
        for _ in 0..<UInt8.max
        {
            XCTAssertNotEqual(pool.getReusableSlotCount(), 0)
            let _ = try! pool.add( Foo() )
            pool.release(index: 0)
        }

        XCTAssertEqual(pool.getReusableSlotCount(), 0)
        XCTAssertThrowsError(try pool.add( Foo() ))
    }
}
