import { assertEquals, assertRejects } from "@std/assert";
import { afterEach, beforeEach, describe, it } from "@std/testing/bdd";
import { restore, stub } from "@std/testing/mock";

import {
  opCreateItem,
  opDeleteItem,
  opGetField,
  opGetItem,
  opListItems,
  opListVaults,
  opSetField,
  type OpItem,
  type OpVault,
} from "./op.ts";

// Mock $ from @david/dax
const mockDax = {
  stdout: () => mockDax,
  then: (callback: (result: any) => any) => {
    return callback({
      stdoutJson: mockDax._mockData,
    });
  },
  text: () => Promise.resolve(mockDax._mockText || ""),
  _mockData: null as any,
  _mockText: null as string | null,
};

describe("op.ts", () => {
  let daxStub: any;

  beforeEach(() => {
    // Reset mock data
    mockDax._mockData = null;
    mockDax._mockText = null;

    // Stub the default export from @david/dax
    daxStub = stub(globalThis, "$" as any, () => mockDax);
  });

  afterEach(() => {
    restore();
  });

  describe("opListVaults", () => {
    it("should list vaults successfully", async () => {
      const mockVaults: OpVault[] = [
        {
          id: "vault1",
          name: "Personal",
          content_version: 1,
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-01T00:00:00Z",
          items: 5,
        },
        {
          id: "vault2",
          name: "Work",
          content_version: 1,
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-01T00:00:00Z",
          items: 10,
        },
      ];

      mockDax._mockData = mockVaults;

      const result = await opListVaults();
      assertEquals(result, mockVaults);
    });
  });

  describe("opListItems", () => {
    it("should list items in a vault successfully", async () => {
      const mockItems: OpItem[] = [
        {
          id: "item1",
          title: "GitHub Token",
          version: 1,
          vault: { id: "vault1", name: "Personal" },
          category: "SECURE_NOTE",
        },
        {
          id: "item2",
          title: "Database Password",
          version: 1,
          vault: { id: "vault1", name: "Personal" },
          category: "PASSWORD",
        },
      ];

      mockDax._mockData = mockItems;

      const result = await opListItems("Personal");
      assertEquals(result, mockItems);
    });

    it("should throw error when vault access fails", async () => {
      // Mock a failing command by throwing an error
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Vault not found");
      });

      await assertRejects(
        () => opListItems("NonExistent"),
        Error,
        'Failed to list items in vault "NonExistent"'
      );
    });
  });

  describe("opGetItem", () => {
    it("should get item successfully", async () => {
      const mockItem: OpItem = {
        id: "item1",
        title: "GitHub Token",
        version: 1,
        vault: { id: "vault1", name: "Personal" },
        category: "SECURE_NOTE",
        fields: [
          {
            id: "field1",
            type: "STRING",
            label: "token",
            value: "secret-value",
          },
        ],
      };

      mockDax._mockData = mockItem;

      const result = await opGetItem("GitHub Token", "Personal");
      assertEquals(result, mockItem);
    });

    it("should throw error when item not found", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Item not found");
      });

      await assertRejects(
        () => opGetItem("NonExistent", "Personal"),
        Error,
        'Failed to get item "NonExistent" from vault "Personal"'
      );
    });
  });

  describe("opGetField", () => {
    it("should get field value successfully", async () => {
      mockDax._mockText = "secret-token-value";

      const result = await opGetField("GitHub Token", "token", "Personal");
      assertEquals(result, "secret-token-value");
    });

    it("should handle whitespace in field values", async () => {
      mockDax._mockText = "  secret-value  \n";

      const result = await opGetField("GitHub Token", "token", "Personal");
      assertEquals(result, "secret-value");
    });

    it("should throw error when field access fails", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Field not found");
      });

      await assertRejects(
        () => opGetField("GitHub Token", "nonexistent", "Personal"),
        Error,
        'Failed to get field "nonexistent" from item "GitHub Token"'
      );
    });
  });

  describe("opSetField", () => {
    it("should set field successfully", async () => {
      // Mock successful command (no exception thrown)
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => Promise.resolve());

      await opSetField("GitHub Token", "token", "new-value", "Personal");
      // Should not throw
    });

    it("should throw error when set operation fails", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Operation failed");
      });

      await assertRejects(
        () => opSetField("GitHub Token", "token", "new-value", "Personal"),
        Error,
        "ITEM_OPERATION_FAILED: GitHub Token"
      );
    });
  });

  describe("opCreateItem", () => {
    it("should create item successfully with no fields", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => Promise.resolve());

      await opCreateItem("New Item", "Personal");
      // Should not throw
    });

    it("should create item successfully with fields", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => Promise.resolve());

      await opCreateItem("New Item", "Personal", {
        username: "testuser",
        password: "testpass",
      });
      // Should not throw
    });

    it("should throw error when create operation fails", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Creation failed");
      });

      await assertRejects(
        () => opCreateItem("New Item", "Personal"),
        Error,
        'Failed to create item "New Item"'
      );
    });
  });

  describe("opDeleteItem", () => {
    it("should delete item successfully", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => Promise.resolve());

      await opDeleteItem("Old Item", "Personal");
      // Should not throw
    });

    it("should throw error when delete operation fails", async () => {
      daxStub.restore();
      daxStub = stub(globalThis, "$" as any, () => {
        throw new Error("Delete failed");
      });

      await assertRejects(
        () => opDeleteItem("Old Item", "Personal"),
        Error,
        'Failed to delete item "Old Item"'
      );
    });
  });
});
