public interface IItemContainer
{
    bool ContainsItem(ItemData item);
    int CountItem(ItemData item);
    bool AddItem(ItemData item);
    bool RemoveItem(ItemData item);
    bool IsFull();
}
