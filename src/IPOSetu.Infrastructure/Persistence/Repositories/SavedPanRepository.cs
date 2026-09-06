using IPOSetu.Domain.Entities;
using IPOSetu.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace IPOSetu.Infrastructure.Persistence.Repositories;

public class SavedPanRepository : ISavedPanRepository
{
    private readonly ApplicationDbContext _context;

    public SavedPanRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<SavedPan>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.SavedPans
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<SavedPan?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.SavedPans.FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
    }

    public async Task<SavedPan> CreateAsync(SavedPan pan, CancellationToken cancellationToken = default)
    {
        await _context.SavedPans.AddAsync(pan, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return pan;
    }

    public async Task<SavedPan> UpdateAsync(SavedPan pan, CancellationToken cancellationToken = default)
    {
        _context.SavedPans.Update(pan);
        await _context.SaveChangesAsync(cancellationToken);
        return pan;
    }

    public async Task<bool> DeleteAsync(Guid id, Guid userId, CancellationToken cancellationToken = default)
    {
        var pan = await _context.SavedPans.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId, cancellationToken);
        if (pan == null) return false;

        _context.SavedPans.Remove(pan);
        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<bool> ExistsForUserAsync(Guid userId, string maskedPan, CancellationToken cancellationToken = default)
    {
        return await _context.SavedPans.AnyAsync(p => p.UserId == userId && p.MaskedPan == maskedPan, cancellationToken);
    }
}
