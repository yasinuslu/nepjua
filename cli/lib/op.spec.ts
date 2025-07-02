import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

// Mock the command utility instead of dax directly
vi.mock("./command.ts", () => ({
  default: vi.fn(),
}));

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

// Mock data storage
let mockData: any = null;
let mockText: string | null = null;

describe("op.ts", () => {
  let commandMock: any;

  beforeEach(async () => {
    // Reset mock data
    mockData = null;
    mockText = null;

    // Import and mock the command utility
    const commandModule = await import("./command.ts");
    commandMock = vi.mocked(commandModule.default);

    // Set up the mock to return our chainable API
    commandMock.mockReturnValue({
      stdout: () => ({
        then: (callback: (result: { stdoutJson: any }) => any) => {
          return Promise.resolve(callback({ stdoutJson: mockData }));
        },
      }),
      then: (callback: (result: { stdoutJson: any }) => any) => {
        return Promise.resolve(callback({ stdoutJson: mockData }));
      },
      text: () => Promise.resolve(mockText || ""),
    });
  });

  // Helper function to set up error throwing
  function setupErrorThrow(errorMessage: string) {
    commandMock.mockImplementation(() => {
      throw new Error(errorMessage);
    });
  }

  afterEach(() => {
    vi.restoreAllMocks();
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

      mockData = mockVaults;

      const result = await opListVaults();
      expect(result).toEqual(mockVaults);
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

      mockData = mockItems;

      const result = await opListItems("Personal");
      expect(result).toEqual(mockItems);
    });

    it("should throw error when vault access fails", async () => {
      setupErrorThrow("Vault not found");

      await expect(opListItems("NonExistent")).rejects.toThrow(
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

      mockData = mockItem;

      const result = await opGetItem("GitHub Token", "Personal");
      expect(result).toEqual(mockItem);
    });

    it("should throw error when item not found", async () => {
      setupErrorThrow("Item not found");

      await expect(opGetItem("NonExistent", "Personal")).rejects.toThrow(
        'Failed to get item "NonExistent" from vault "Personal"'
      );
    });
  });

  describe("opGetField", () => {
    it("should get field value successfully", async () => {
      mockText = "secret-token-value";

      const result = await opGetField("GitHub Token", "token", "Personal");
      expect(result).toBe("secret-token-value");
    });

    it("should handle whitespace in field values", async () => {
      mockText = "  secret-value  \n";

      const result = await opGetField("GitHub Token", "token", "Personal");
      expect(result).toBe("secret-value");
    });

    it("should throw error when field access fails", async () => {
      setupErrorThrow("Field not found");

      await expect(
        opGetField("GitHub Token", "nonexistent", "Personal")
      ).rejects.toThrow(
        'Failed to get field "nonexistent" from item "GitHub Token"'
      );
    });
  });

  describe("opSetField", () => {
    it("should set field successfully", async () => {
      // Mock successful command (no exception thrown)
      commandMock.mockReturnValue(Promise.resolve());

      await opSetField("GitHub Token", "token", "new-value", "Personal");
      // Should not throw
    });

    it("should throw error when set operation fails", async () => {
      setupErrorThrow("Operation failed");

      await expect(
        opSetField("GitHub Token", "token", "new-value", "Personal")
      ).rejects.toThrow("ITEM_OPERATION_FAILED: GitHub Token");
    });
  });

  describe("opCreateItem", () => {
    it("should create item successfully with no fields", async () => {
      commandMock.mockReturnValue(Promise.resolve());

      await opCreateItem("New Item", "Personal");
      // Should not throw
    });

    it("should create item successfully with fields", async () => {
      commandMock.mockReturnValue(Promise.resolve());

      await opCreateItem("New Item", "Personal", {
        username: "testuser",
        password: "testpass",
      });
      // Should not throw
    });

    it("should throw error when create operation fails", async () => {
      setupErrorThrow("Creation failed");

      await expect(opCreateItem("New Item", "Personal")).rejects.toThrow(
        'Failed to create item "New Item"'
      );
    });
  });

  describe("opDeleteItem", () => {
    it("should delete item successfully", async () => {
      commandMock.mockReturnValue(Promise.resolve());

      await opDeleteItem("Old Item", "Personal");
      // Should not throw
    });

    it("should throw error when delete operation fails", async () => {
      setupErrorThrow("Delete failed");

      await expect(opDeleteItem("Old Item", "Personal")).rejects.toThrow(
        'Failed to delete item "Old Item"'
      );
    });
  });
});
