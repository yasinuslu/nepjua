import { describe, expect, it, vi } from "vitest";
import { $ } from "./command.ts";
import {
  opCreateItem,
  opDeleteItem,
  opGetItem,
  opListItems,
  opSetField,
} from "./op.ts";

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
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: mockItem, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      const result = await opGetItem("Test Item", "my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(mockChain.stdout).toHaveBeenCalledWith("piped");
      expect(mockChain.then).toHaveBeenCalled();
      expect(result).toEqual(mockItem);
    });

    it("should handle errors", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi.fn().mockRejectedValue(new Error("Item not found")),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      await expect(opGetItem("Missing Item", "my-vault")).rejects.toThrow(
        'Failed to get item "Missing Item" from vault "my-vault"'
      );
    });
  });

  describe("opSetField", () => {
    it("should set field by item name and vault", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      await opSetField("Test Item", "password", "new-password", "my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(mockChain.exec).toHaveBeenCalled();
    });

    it("should handle errors", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockRejectedValue(new Error("Permission denied")),
      };
      mock$.mockReturnValue(mockChain);

      await expect(
        opSetField("Test Item", "password", "new-password", "my-vault")
      ).rejects.toThrow("ITEM_OPERATION_FAILED: Test Item");
    });
  });

  describe("opCreateItem", () => {
    it("should create item with fields", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      const fields = {
        username: "test-user",
        password: "test-pass",
      };

      await opCreateItem("Test Item", "my-vault", fields);

      expect(mock$).toHaveBeenCalled();
      expect(mockChain.exec).toHaveBeenCalled();
    });

    it("should handle creation errors", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockRejectedValue(new Error("Item already exists")),
      };
      mock$.mockReturnValue(mockChain);

      await expect(opCreateItem("Test Item", "my-vault", {})).rejects.toThrow(
        'Failed to create item "Test Item"'
      );
    });
  });

  describe("opDeleteItem", () => {
    it("should delete item by name and vault", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      await opDeleteItem("Test Item", "my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(mockChain.exec).toHaveBeenCalled();
    });

    it("should handle deletion errors", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: {}, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockRejectedValue(new Error("Item not found")),
      };
      mock$.mockReturnValue(mockChain);

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
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi
          .fn()
          .mockImplementation((callback) =>
            callback({ stdoutJson: mockItems, text: "" })
          ),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      const result = await opListItems("my-vault");

      expect(mock$).toHaveBeenCalled();
      expect(mockChain.stdout).toHaveBeenCalledWith("piped");
      expect(mockChain.then).toHaveBeenCalled();
      expect(result).toEqual(mockItems);
    });

    it("should handle listing errors", async () => {
      const mockChain = {
        stdout: vi.fn().mockReturnThis(),
        then: vi.fn().mockRejectedValue(new Error("Vault not found")),
        text: vi.fn().mockResolvedValue(""),
        exec: vi.fn().mockResolvedValue(undefined),
      };
      mock$.mockReturnValue(mockChain);

      await expect(opListItems("missing-vault")).rejects.toThrow(
        'Failed to list items in vault "missing-vault"'
      );
    });
  });
});
