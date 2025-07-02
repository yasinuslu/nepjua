import { describe, expect, it, vi } from "vitest";
import { $ } from "./$.ts";
import {
  opCreateItem,
  opDeleteItem,
  opGetItem,
  opListItems,
  opSetField,
} from "./op.ts";
import { createMock$ } from "./test-utils.ts";

// Get access to the mocked $ function
const mock$ = vi.mocked($);

describe("op.ts", () => {
  describe("opGetItem", () => {
    it("should get item by name and vault", async () => {
      const mockItem = {
        id: "1",
        title: "Test Item",
        vault: { name: "my-vault" },
      };

      mock$.mockReturnValue(createMock$({ json: mockItem }));

      const result = await opGetItem("Test Item", "my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(result).toEqual(mockItem);
    });

    it("should handle errors", async () => {
      const error = new Error("Item not found");
      mock$.mockReturnValue(createMock$({ error }));

      await expect(opGetItem("Missing Item", "my-vault")).rejects.toThrow(
        'Failed to get item "Missing Item" from vault "my-vault"'
      );
    });
  });

  describe("opSetField", () => {
    it("should set field by item name and vault", async () => {
      mock$.mockReturnValue(createMock$({}));

      await opSetField("Test Item", "password", "new-password", "my-vault");

      expect(mock$).toHaveBeenCalled();
    });

    it("should handle errors", async () => {
      const error = new Error("Permission denied");
      mock$.mockReturnValue(createMock$({ error }));

      await expect(
        opSetField("Test Item", "password", "new-password", "my-vault")
      ).rejects.toThrow("ITEM_OPERATION_FAILED: Test Item");
    });
  });

  describe("opCreateItem", () => {
    it("should create item with fields", async () => {
      mock$.mockReturnValue(createMock$({}));

      const fields = {
        username: "test-user",
        password: "test-pass",
      };

      await opCreateItem("Test Item", "my-vault", fields);

      expect(mock$).toHaveBeenCalled();
    });

    it("should handle creation errors", async () => {
      const error = new Error("Item already exists");
      mock$.mockReturnValue(createMock$({ error }));

      await expect(opCreateItem("Test Item", "my-vault", {})).rejects.toThrow(
        'Failed to create item "Test Item"'
      );
    });
  });

  describe("opDeleteItem", () => {
    it("should delete item by name and vault", async () => {
      mock$.mockReturnValue(createMock$({}));

      await opDeleteItem("Test Item", "my-vault");

      expect(mock$).toHaveBeenCalled();
    });

    it("should handle deletion errors", async () => {
      const error = new Error("Item not found");
      mock$.mockReturnValue(createMock$({ error }));

      await expect(opDeleteItem("Missing Item", "my-vault")).rejects.toThrow(
        'Failed to delete item "Missing Item"'
      );
    });
  });

  describe("opListItems", () => {
    it("should list items by vault", async () => {
      const mockItems = [
        { id: "1", title: "Item 1" },
        { id: "2", title: "Item 2" },
      ];

      mock$.mockReturnValue(createMock$({ json: mockItems }));

      const result = await opListItems("my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(result).toEqual(mockItems);
    });

    it("should handle listing errors", async () => {
      const error = new Error("Vault not found");
      mock$.mockReturnValue(createMock$({ error }));

      await expect(opListItems("missing-vault")).rejects.toThrow(
        'Failed to list items in vault "missing-vault"'
      );
    });
  });
});
